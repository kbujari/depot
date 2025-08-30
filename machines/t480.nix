{ inputs, flake, perSystem, pkgs, ... }:
let
  inherit (inputs.nixos-hardware.nixosModules)
    lenovo-thinkpad-t480
    ;

  inherit (import flake.outputs.nixosModules.users { inherit perSystem pkgs; }) kle;
in
{
  imports = [
    lenovo-thinkpad-t480
    flake.outputs.nixosModules.desktop
  ];

  nixpkgs.hostPlatform.system = "x86_64-linux";
  system.stateVersion = "24.05";

  xnet = {
    # desktop.enable = true;
    disk = {
      enable = true;
      device = "/dev/nvme0n1";
    };
  };

  users.users.kle = kle;

  networking = {
    hostName = "t480";
    useDHCP = false;
    dhcpcd.enable = false;
    networkmanager = {
      enable = true;
      # dns = "none";
      wifi.powersave = true;
    };
  };

  programs.nm-applet.enable = true;
  services.fwupd.enable = true;

  xnet.persist = [ "/etc/NetworkManager/system-connections" ];
}
