{ inputs, ... }:
let
  inherit (inputs.nixos-hardware.nixosModules)
    lenovo-thinkpad-t480
    ;
in
{
  imports = [
    lenovo-thinkpad-t480
  ];

  system.stateVersion = "24.05";

  xnet = {
    desktop.enable = true;
    users.enable = [ "kle" ];
    disk = {
      enable = true;
      device = "/dev/nvme0n1";
    };
  };

  networking = {
    hostName = "t480";
    useDHCP = false;
    dhcpcd.enable = false;
    nameservers = [ "9.9.9.9" ];
    networkmanager = {
      enable = true;
      dns = "none";
      wifi.powersave = true;
    };
  };

  programs.nm-applet.enable = true;
  services.fwupd.enable = true;

  xnet.persist = [ "/etc/NetworkManager/system-connections" ];
}
