{ inputs, flake, pkgs, config, ... }:
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
    # ./jellyfin.nix
    ./pxeboot.nix
    flake.outputs.nixosModules.disk
    flake.outputs.nixosModules.network
  ];

  nixpkgs.hostPlatform.system = "x86_64-linux";
  system.stateVersion = "24.11";
  networking.hostName = "radon";

  users.groups.media.gid = 2000;

  boot.zfs.pools.radon.devNodes = "/dev/disk/by-id/";
  boot.zfs.extraPools = [ "radon" ];

  services.nfs.server.enable = true;
  networking.firewall.allowedTCPPorts = [ 2049 ];

  # depot.disk = {
  #   enable = true;
  #   device = "/dev/nvme0n1";
  # };

  depot.net = {
    v6Token = "::cafe";
    sshd.enable = true;
    sshd.publish = true;
  };

  xnet = {
    nginx.enable = true;
    disk = {
      enable = true;
      device = "/dev/nvme0n1";
    };
    gitServer = {
      enable = true;
      gitweb.enable = true;
    };
  };
}
