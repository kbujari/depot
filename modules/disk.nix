{ config, pkgs, lib, modulesPath, inputs, ... }:
let
  cfg = config.depot.disk;

  inherit (lib) mkOption mkDefault mkIf types;
in
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    inputs.disko.nixosModules.default
  ];

  options.depot.disk = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Apply depot-standard ZFS disk layout.";
    };

    device = mkOption {
      type = types.str;
      description = "Device used for zroot ZFS pool.";
    };
  };

  config = mkIf cfg.enable {
    networking.hostId = builtins.substring 0 8
      (builtins.hashString "md5" config.networking.hostName);

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
      kernelParams = [ "nohibernate" "elevator=none" ];
      supportedFilesystems = [ "vfat" "zfs" ];
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
      mountOptions = [ "defaults" "size=2G" "mode=755" ];
    };

    disko.devices.disk.main = {
      type = "disk";
      device = cfg.device;
      imageSize = "15G";
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
        "com.sun:auto-snapshot" = "false";
        acltype = "posixacl";
        atime = "off";
        compression = "on";
        normalization = "formD";
        relatime = "off";
        xattr = "sa";
      };

      datasets.nix = {
        type = "zfs_fs";
        mountpoint = "/nix";
        options.mountpoint = "legacy";
      };

      # datasets.reserved = {
      #   type = "zfs_fs";
      #   options = {
      #     refreservation = "10G";
      #     mountpoint = "none";
      #   };
      # };

      datasets.home = {
        type = "zfs_fs";
        mountpoint = "/home";
        options.mountpoint = "legacy";
      };

      # datasets.persist = {
      #   type = "zfs_fs";
      #   mountpoint = "/persist";
      #   options.mountpoint = "legacy";
      # };
    };
  };
}
