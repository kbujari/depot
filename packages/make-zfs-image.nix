# This single-disk approach does not satisfy ZFS's requirements for autoexpand,
# however automation can expand it anyway. For example, with
# `services.zfs.expandOnBoot`.
{
  pkgs,
  lib,
  config,

  # size of the FAT partition, in MiB (1024x1024 bytes).
  bootSize ? 1024,

  # memory allocated for virtualized build instance, in MiB (1024x1024 bytes).
  memSize ? 2048,

  # The size of the root partition, in MiB (1024x1024 bytes).
  rootSize ? 4096,

  # Shell code executed after the VM has finished.
  postVM ? "",

  name ? "nixos-disk-image",

  # Disk image format, one of qcow2, qcow2-compressed, vdi, vpc, raw.
  format ? "raw",
}:
let
  formatOpt = if format == "qcow2-compressed" then "qcow2" else format;

  compress = lib.optionalString (format == "qcow2-compressed") "-c";

  filenameSuffix =
    "."
    + {
      qcow2 = "qcow2";
      vdi = "vdi";
      vpc = "vhd";
      raw = "img";
    }
    .${formatOpt} or formatOpt;
  rootFilename = "nixos.root${filenameSuffix}";

  closureInfo = pkgs.closureInfo {
    rootPaths = [ config.system.build.toplevel ];
  };

  vmTools = pkgs.vmTools.override {
    rootModules = [
      "virtio_blk"
      "virtio_pci"
      "virtiofs"
      "zfs"
    ];
    kernel = pkgs.aggregateModules (
      with config.boot;
      [
        kernelPackages.kernel
        (lib.getOutput "modules" kernelPackages.kernel)
        kernelPackages.${pkgs.zfs.kernelModuleAttribute}
      ]
    );
  };

  binPath = lib.makeBinPath (
    with pkgs;
    [
      config.system.build.nixos-install
      dosfstools
      nix
      parted
      util-linux
      zfs
    ]
    ++ stdenv.initialPath
  );

  image = vmTools.runInLinuxVM (
    pkgs.runCommand name
      {
        inherit memSize;
        QEMU_OPTS = "-drive file=$rootDiskImage,if=virtio,cache=unsafe,werror=report";
        preVM = ''
          mkdir $out

          rootDiskImage=root.raw
          ${pkgs.qemu-utils}/bin/qemu-img create -f raw $rootDiskImage ${toString (bootSize + rootSize)}M
        '';

        postVM = ''
          # truncate --size ${toString (bootSize + rootSize)} $rootDiskImage
          ${
            if formatOpt == "raw" then
              ''
                mv $rootDiskImage $out/${rootFilename}
              ''
            else
              ''
                ${pkgs.qemu-utils}/bin/qemu-img convert -f raw -O ${formatOpt} ${compress} $rootDiskImage $out/${rootFilename}
              ''
          }
          rootDiskImage=$out/${rootFilename}
          set -x
          ${postVM}
        '';
      }
      ''
        export PATH=${binPath}

        parted --script /dev/vda -- \
          mklabel gpt \
          mkpart ESP fat32 8MiB ${toString bootSize}MiB \
          set 1 esp on \
          align-check optimal 1 \
          mkpart primary ${toString bootSize}MiB 100% \
          align-check optimal 2 \
          print

        zpool create \
          -o ashift=12 -o autotrim=on -o autoexpand=on \
          -O acltype=posixacl -O atime=off -O compression=on \
          -O mountpoint=none -O normalization=formD -O relatime=off \
          -O xattr=sa -O canmount=off \
          zroot /dev/vda2

        zfs create zroot/local
        zfs create zroot/local/var -o mountpoint=/var -u
        zfs create zroot/local/nix -o mountpoint=legacy

        mkdir -p /mnt/boot
        mkfs.vfat -n ESP /dev/vda1
        mount /dev/vda1 /mnt/boot

        mkdir -p /mnt/nix
        mount -t zfs zroot/local/nix /mnt/nix

        export HOME=$TMPDIR

        # Provide a Nix database so that nixos-install can copy closures.
        export NIX_STATE_DIR=$TMPDIR/state
        nix-store --load-db < ${closureInfo}/registration

        chmod 755 $TMPDIR
        nixos-install \
          --root /mnt \
          --no-root-passwd \
          --system ${config.system.build.toplevel} \
          --substituters ""

        umount --recursive /mnt/boot
        umount --recursive /mnt/nix
        zpool export zroot
      ''
  );
  script = pkgs.writeShellScriptBin "runvm" ''
    cp ${image}/nixos.root.qcow2 nixos.root.qcow2
    ${pkgs.qemu-utils}/bin/qemu-img resize nixos.root.qcow2 +10G
    ${pkgs.qemu}/bin/qemu-system-x86_64 \
      -enable-kvm \
      -m 4G \
      -cpu host \
      -bios ${pkgs.OVMF.fd}/FV/OVMF.fd \
      -drive file=nixos.root.qcow2,format=qcow2,if=virtio \
      -boot order=c
  '';
in
script
