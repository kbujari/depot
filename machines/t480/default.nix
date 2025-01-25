{ inputs, depot, ... }:
let
  inherit (inputs.nixos-hardware.nixosModules)
    lenovo-thinkpad-t480
    ;

  inherit (depot.users)
    kle
    ;
in
{
  imports = [
    lenovo-thinkpad-t480
  ];

  system.stateVersion = "24.05";

  xnet = {
    desktop.enable = true;
    # users.enable = [ "kle" ];
    disk = {
      enable = true;
      device = "/dev/nvme0n1";
    };
  };

  users.users.kle = kle.nixos;

  networking = {
    hostName = "t480";
    useDHCP = false;
    dhcpcd.enable = false;
    nameservers = [ "127.0.0.1" ];
    networkmanager = {
      enable = true;
      dns = "none";
      wifi.powersave = true;
    };
  };

  programs.nm-applet.enable = true;
  services.fwupd.enable = true;

  services.unbound = {
    enable = true;
    settings.server = {
      interface = [ "127.0.0.1" ];
      port = 53;
      access-control = [ "127.0.0.1 allow" ];
      harden-glue = true;
      harden-dnssec-stripped = true;
      use-caps-for-id = false;
      prefetch = true;
      edns-buffer-size = 1232;
      hide-identity = true;
      hide-version = true;
    };

    settings.forward-zone = [
      {
        name = ".";
        forward-tls-upstream = true;
        forward-addr = [
          "9.9.9.9#dns.quad9.net"
          "149.112.112.112#dns.quad9.net"
        ];
      }
    ];
  };

  xnet.persist = [ "/etc/NetworkManager/system-connections" ];
}
