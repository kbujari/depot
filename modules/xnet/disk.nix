{ config, lib, modulesPath, inputs, ... }:
let
  cfg = config.xnet.disk;
  commonOpts = {
    acltype = "posixacl";
    atime = "off";
    compression = "on";
    normalization = "formD";
    relatime = "off";
    xattr = "sa";
    "com.sun:auto-snapshot" = "false";
  };

  inherit (lib) mkOption mkDefault mkIf types;
in
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    inputs.disko.nixosModules.default
  ];

  options.xnet.disk = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Apply xnet-standard ZFS disk layout.";
    };

    device = mkOption {
      type = types.str;
      description = "Device used for zroot ZFS pool.";
    };
  };

  config = mkIf cfg.enable {
    networking.hostId = builtins.substring 0 8
      (builtins.hashString "md5" config.networking.hostName);

    services.zfs = {
      autoScrub.enable = true;
      trim.enable = true;
    };

    # With root running in memory, swap should be required unless
    # otherwise specified
    zramSwap.enable = mkDefault true;

    boot = {
      kernelParams = [ "nohibernate" "elevator=none" ];
      supportedFilesystems = [ "vfat" "zfs" ];
      zfs.devNodes = mkDefault "/dev/disk/by-partuuid";
      loader = {
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
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
      tmp.cleanOnBoot = mkDefault true;
    };

    disko.devices.disk.main = {
      type = "disk";
      device = cfg.device;
      content = {
        type = "gpt";
        partitions.ESP = {
          size = "1G";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
          };
        };
        partitions.ZFS = {
          size = "100%";
          content = {
            type = "zfs";
            pool = "zroot";
          };
        };
      };
    };

    disko.devices = {
      nodev."/" = {
        fsType = "tmpfs";
        mountOptions = [ "defaults" "size=2G" "mode=755" ];
      };

      zpool.zroot = {
        type = "zpool";
        options = {
          ashift = "12";
          autotrim = "on";
        };

        datasets = {
          "local" = {
            type = "zfs_fs";
            options = commonOpts // {
              mountpoint = "none";
            };
          };

          "local/nix" = {
            type = "zfs_fs";
            mountpoint = "/nix";
            options.mountpoint = "legacy";
          };

          "local/reserved" = {
            type = "zfs_fs";
            options = {
              refreservation = "10G";
              mountpoint = "none";
            };
          };

          "persist" = {
            type = "zfs_fs";
            mountpoint = "/persist";
            options = commonOpts // {
              mountpoint = "legacy";
            };
          };
        };
      };
    };

    services.sanoid = {
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
}
