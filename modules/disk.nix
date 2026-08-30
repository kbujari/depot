{
  config,
  pkgs,
  lib,
  modulesPath,
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
    (modulesPath + "/image/file-options.nix")
  ];

  options.depot.disk = {
    enable = lib.mkEnableOption "Apply depot-standard ZFS disk layout.";
    persistHome = lib.mkEnableOption "Persist home directories.";

    reserved = lib.mkOption {
      type = types.ints.positive;
      description = "Space (in GB) to reserve as unusable on disk.";
      default = 10;
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
        datasets."zroot/local/var" = {
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
        "rd.systemd.unit=rescue.target"
      ];
      supportedFilesystems = [
        "vfat"
        "zfs"
      ];
      zfs.devNodes = mkDefault "/dev/disk/by-partuuid";
      loader.efi.canTouchEfiVariables = true;
      loader.systemd-boot = {
        enable = true;
        memtest86.enable = true;
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

    services.getty.autologinUser = "root";
    fileSystems = {
      "/" = {
        device = "nodev";
        fsType = "tmpfs";
        options = [
          "defaults"
          "size=2G"
          "mode=755"
        ];
      };

      "/nix" = {
        device = "zroot/local/nix";
        fsType = "zfs";
      };

      "/boot" = {
        device = "/dev/disk/by-partlabel/ESP";
        fsType = "vfat";
        options = [ "umask=0077" ];
      };
    };

    boot.initrd.systemd.services."growroot" = {
      description = "Grow main partition into any unused disk space.";
      serviceConfig.Type = "oneshot";

      # If dry-run fails, there is nothing to grow
      serviceConfig.ExecCondition = "${pkgs.cloud-utils}/bin/growpart /dev/vda 2 --dry-run";

      wantedBy = [ "zfs.target" ];
      before = [ "zfs-import-zroot.service" ];

      script = "growpart /dev/vda 2 --verbose";
    };

    boot.initrd.systemd.services."expand-zroot" = {
      description = "Expand zroot to take up entire partition.";
      serviceConfig.Type = "oneshot";

      wantedBy = ["zfs.target"];
      after = ["zfs-import-zroot.service"];

      script = ''
        # pull partuuid from zpool
        GUID=$(zpool list -v --json | jq --raw-output '.pools.zroot.vdevs.[].name')

        # re-mark pool as online with '-e' to expand
        zpool online -e zroot $GUID
      '';
    };

    boot.initrd.systemd.emergencyAccess = true;
    boot.initrd.systemd.initrdBin = [
      pkgs.cloud-utils
      pkgs.util-linux
      pkgs.busybox
      pkgs.jq
      pkgs.zfs
    ];

    image.modules.depot =
      { config, modulesPath, ... }:
      {
        imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

        image.extension = "qcow2";
        system.build.image = pkgs.depot.make-zfs-image.override {
          inherit pkgs lib config;
          inherit (config.image) fileName extension;
        };
      };

    #   datasets =
    #     let
    #       inherit (lib)
    #         genAttrs
    #         ;

    #       mounts = [
    #         # Any machine importing this configuration will require a
    #         # nix store, so it needs to survive reboots.
    #         "nix"

    #         # Although it goes against the idea of putting root on a
    #         # tmpfs, SystemD stores useful state for timers, services,
    #         # logs, etc. in var.
    #         "var"

    #         # Most machines using this module do not define additional
    #         # users, so /root should persist as the only "home" on the
    #         # system.
    #         "root"

    #         # General storage that should outlive a reboot. Paths
    #         # mentioned in Nix configs should generally use this
    #         # directory rather than /var or other directories that
    #         # happen to also be saved.
    #         "persist"
    #       ] ++ lib.optional cfg.persistHome "home";

    #       makeDataset = name: {
    #         type = "zfs_fs";
    #         mountpoint = "/${name}";
    #         options.mountpoint = "legacy";
    #       };
    #     in
    #     genAttrs mounts makeDataset
    #     // {
    #       # ZFS should not use all available space on a device. This
    #       # reserves some space at pool creation time that is never mounted
    #       # to ensure it never happens.
    #       reserved = {
    #         type = "zfs_fs";
    #         options = {
    #           refreservation = "${toString cfg.reserved}G";
    #           mountpoint = "none";
    #         };
    #       };
    #     };
    # };
  };
}
