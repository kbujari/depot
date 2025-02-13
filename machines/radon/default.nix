{ inputs, ... }:
let

  inherit (inputs.nixos-hardware.nixosModules)
    common-cpu-intel
    common-gpu-intel
    ;

  interfaces = {
    bottom = "enp1s0";
    top = "enp2s0";
  };
in
{
  imports = [
    common-cpu-intel
    common-gpu-intel
    ./jellyfin.nix
    ./pxeboot.nix
  ];

  system.stateVersion = "24.11";
  networking.hostName = "radon";

  boot.kernel.sysctl = {
    "net.ipv4.conf.all.forwarding" = true;
    "net.ipv6.conf.all.forwarding" = true;
  };

  services.unbound.settings.server = {
    interface = [ "10.88.88.2" ];
    access-control = [
      "10.88.88.0/24 allow"
    ];
  };

  networking.firewall.interfaces.plaza = {
    allowedTCPPorts = [ 53 ];
    allowedUDPPorts = [ 53 ];
  };

  users.groups.media.gid = 2000;

  boot.zfs.pools.radon.devNodes = "/dev/disk/by-id/";
  boot.zfs.extraPools = [ "radon" ];

  services.nfs.server.enable = true;

  xnet = {
    disk = {
      enable = true;
      device = "/dev/nvme0n1";
    };
    net = {
      join = [ "plaza" ];
      interface = interfaces.bottom;
      sshd.enable = true;
    };
    nginx.enable = true;
    gitServer = {
      enable = true;
      gitweb.enable = true;
    };
  };
}
