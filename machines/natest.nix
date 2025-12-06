{ config, modulesPath, pkgs, lib, ... }:

{
  imports = [
    #   flake.outputs.nixosModules.disk
    #   flake.outputs.nixosModules.desktop
    (modulesPath + "/image/repart.nix")
  ];

  system.stateVersion = "25.05";
  nixpkgs.hostPlatform = "x86_64-linux";

  users.users.alice = {
    group = "wheel";
    isNormalUser = true;
    initialPassword = "hello";
  };

  fileSystems = {
    "/" = {
      fsType = "tmpfs";
      options = [ "defaults" "mode=755" "size=2G" ];
    };
    "/boot" = {
      device = "/dev/disk/by-partlabel/boot";
      fsType = "vfat";
    };
    "/nix/store" = {
      device = "/dev/disk/by-partlabel/nix-store";
      fsType = "ext4";
    };
    "/var" = {
      device = "/dev/disk/by-partlabel/var";
      fsType = "ext4";
    };
    "/home" = {
      device = "/dev/disk/by-partlabel/home";
      fsType = "ext4";
    };
  };

  image.repart =
    let
      inherit (pkgs.stdenv.hostPlatform) efiArch;
    in
      {
        name = "image";
        partitions.esp = {
          repartConfig = {
            Format = "vfat";
            Label = "boot";
            SizeMinBytes = "256M";
            Type = "esp";
          };
          contents = {
            "/EFI/BOOT/BOOT${lib.toUpper efiArch}.EFI".source =
              "${pkgs.systemd}/lib/systemd/boot/efi/systemd-boot${efiArch}.efi";

            # "/EFI/Linux/${config.system.boot.loader.ukiFile}".source =
            #   "${config.system.build.uki}/${config.system.boot.loader.ukiFile}";

            "/EFI/nixos/${config.system.boot.loader.kernelFile}.efi".source =
              "${config.system.build.kernel}/${config.system.boot.loader.kernelFile}";

            "/EFI/nixos/${config.system.boot.loader.initrdFile}.efi".source =
              "${config.system.build.initialRamdisk}/${config.system.boot.loader.initrdFile}";

            "/loader/entries/nixos.conf".source =
              pkgs.writeText "default-entry.conf" ''
                title Coolio
                linux /EFI/nixos/${config.system.boot.loader.kernelFile}.efi
                initrd /EFI/nixos/${config.system.boot.loader.initrdFile}.efi
                options init=${config.system.build.toplevel}/init root=fstab loglevel=4
              '';

            "/loader/loader.conf".source =
              pkgs.writeText "loader.conf" ''
                timeout 5
                console-mode keep
              '';
          };
        };
        partitions.nix-store = {
          storePaths = [ config.system.build.toplevel ];
          nixStorePrefix = "/";
          repartConfig = {
            Format = "ext4";
            Label = "nix-store";
            SizeMinBytes = "4G";
            Type = "linux-generic";
          };
        };
      };

  boot.loader.systemd-boot = {
    enable = true;
    memtest86.enable = true;
  };

  boot.initrd.systemd = {
    enable = true;
    repart.enable = true;
  };

  systemd.repart.partitions = {
    home = {
      Format = "ext4";
      Label = "home";
      Type = "home";
      Weight = "2000";
    };
    var = {
      Format = "ext4";
      Label = "var";
      Type = "var";
      Weight = "1000";
    };
  };
}
