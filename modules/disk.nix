{
  config,
  pkgs,
  lib,
  modulesPath,
  inputs,
  ...
}:
let
  cfg = config.depot.disk;

  inherit (lib)
    mkIf
    mkDefault
    types
    ;
in
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    inputs.disko.nixosModules.default
  ];

  options.depot.disk = {
    enable = lib.mkEnableOption "Apply depot-standard ZFS disk layout.";
    persistHome = lib.mkEnableOption "Persist home directories.";
    device = lib.mkOption {
      type = types.str;
      description = "Name of device to install to.";
    };
  };

  config = mkIf cfg.enable {
    networking.hostId = builtins.substring 0 8 (builtins.hashString "md5" config.networking.hostName);

    services = {
      zfs.autoScrub.enable = true;
      zfs.trim.enable = true;
      sanoid = {
        enable = true;
        templates.default = {
          autosnap = true;
          autoprune = true;
          hourly = 24;
          daily = 14;
          monthly = 1;
        };
        datasets."zroot/persist" = {
          useTemplate = [ "default" ];
          recursive = true;
        };
      };
    };

    # With root running in memory, swap should be required unless
    # otherwise specified
    zramSwap.enable = mkDefault true;

    boot = {
      kernelParams = [
        "nohibernate"
        "elevator=none"
      ];
      supportedFilesystems = [
        "vfat"
        "zfs"
      ];
      zfs.devNodes = mkDefault "/dev/disk/by-partuuid";
      loader.efi.canTouchEfiVariables = true;
      loader.systemd-boot = {
        enable = true;
        extraFiles."efi/ipxe.efi" = "${pkgs.ipxe}/ipxe.efi";
        extraEntries."ipxe.conf" = ''
          title iPXE
          efi /efi/ipxe.efi
          sortkey z-ipxe
        '';
      };
      initrd = {
        systemd.enable = true;
        availableKernelModules = [
          "xhci_pci"
          "ahci"
          "nvme"
          "usb_storage"
          "sd_mod"
          "sdhci_pci"
        ];
      };
    };

    disko.devices.nodev."/" = {
      fsType = "tmpfs";
      mountOptions = [
        "defaults"
        "size=2G"
        "mode=755"
      ];
    };

    disko.devices.disk.main = {
      imageSize = "32G";
      device = cfg.device;
      type = "disk";
      content = {
        type = "gpt";
        partitions.ESP = {
          size = "1G";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };
        partitions.ZFS = {
          size = "100%";
          content.type = "zfs";
          content.pool = "zroot";
        };
      };
    };

    disko.devices.zpool.zroot = {
      type = "zpool";

      options = {
        ashift = "12";
        autotrim = "on";
      };

      rootFsOptions = {
        acltype = "posixacl";
        atime = "off";
        compression = "on";
        mountpoint = "none";
        normalization = "formD";
        relatime = "off";
        xattr = "sa";
      };

      datasets =
        let
          inherit (lib)
            genAttrs
            ;

          mounts = [
            # Any machine importing this configuration will require a
            # nix store, so it needs to survive reboots.
            "nix"

            # Although it goes against the idea of putting root on a
            # tmpfs, SystemD stores useful state for timers, services,
            # logs, etc. in var.
            "var"

            # Most machines using this module do not define additional
            # users, so /root should persist as the only "home" on the
            # system.
            "root"

            # General storage that should outlive a reboot. Paths
            # mentioned in Nix configs should generally use this
            # directory rather than /var or other directories that
            # happen to also be saved.
            "persist"
          ] ++ lib.optional cfg.persistHome "home";

          makeDataset = name: {
            type = "zfs_fs";
            mountpoint = "/${name}";
            options.mountpoint = "legacy";
          };
        in
        genAttrs mounts makeDataset
        // {
          # ZFS should not use all available space on a device. This
          # reserves some space at pool creation time that is never mounted
          # to ensure it never happens.
          reserved = {
            type = "zfs_fs";
            options = {
              refreservation = "10G";
              mountpoint = "none";
            };
          };
        };
    };
  };
}
