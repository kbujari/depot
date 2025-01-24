{ lib, inputs, ... }:
let
  gitKeys = builtins.fetchurl {
    url = "https://github.com/kbujari.keys";
    sha256 = "0fpa679zkrpx77vangzf3gnidwvmky8ifivn8411xx6albrikaqx";
  };

  inherit (inputs.nixos-hardware.nixosModules)
    common-cpu-intel
    common-gpu-intel
    ;
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

  users.users.root.initialPassword = "hello";

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
      interface = "enp1s0";
      sshd.enable = true;
    };
    nginx.enable = true;
    gitServer = {
      enable = true;
      gitweb.enable = true;
      keys = lib.splitString "\n" (builtins.readFile gitKeys);
    };
  };
}
