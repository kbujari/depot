{ inputs, flake, pkgs, config, ... }:
let
  interfaces = {
    bottom = "enp1s0";
    top = "enp2s0";
  };
in
{
  imports = [
    # ./jellyfin.nix
    ./pxeboot.nix
    flake.outputs.nixosModules.disk
    flake.outputs.nixosModules.intel
    flake.outputs.nixosModules.network
  ];

  nixpkgs.hostPlatform.system = "x86_64-linux";
  networking.hostName = "radon";

  users.groups.media.gid = 2000;

  # boot.zfs.pools.radon.devNodes = "/dev/disk/by-id/";
  # boot.zfs.extraPools = [ "radon" ];

  services.nfs.server.enable = true;
  networking.firewall.allowedTCPPorts = [ 2049 ];

  depot.disk.enable = true;

  depot.net = {
    v6Token = "::cafe";
    sshd.enable = true;
    sshd.publish = true;
  };

  xnet = {
    nginx.enable = true;
    # disk = {
    #   enable = true;
    #   device = "/dev/nvme0n1";
    # };
    gitServer = {
      enable = true;
      gitweb.enable = true;
    };
  };
}
