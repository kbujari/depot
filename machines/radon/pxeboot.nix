{ pkgs, lib, ... }:
let
  installer = lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      ({ config, pkgs, lib, modulesPath, ... }: {
        imports = [
          (modulesPath + "/installer/netboot/netboot-minimal.nix")
          (modulesPath + "/installer/cd-dvd/channel.nix")
        ];

        services.openssh = {
          enable = true;
          openFirewall = true;
          settings = {
            PasswordAuthentication = false;
            KbdInteractiveAuthentication = false;
          };
        };

        nix.settings = {
          experimental-features = [ "nix-command" "flakes" ];
        };

        users.users.root.openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP7T2uWJFUu8aFZZgQusGKyEMocb2pKbHLDad2eIJus9"
        ];
      })
    ];
  };

  inherit (installer.config.system) build;
in
{
  services.pixiecore = {
    enable = true;
    openFirewall = true;
    kernel = "${build.kernel}/bzImage";
    initrd = "${build.netbootRamdisk}/initrd";
    cmdLine = "init=${build.toplevel}/init loglevel=4";
    mode = "boot";
    port = 8001;
    statusPort = 8001;

    # Piggyback on existing network DHCP
    dhcpNoBind = true;
  };
}
