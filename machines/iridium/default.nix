{ lib, inputs, depot, ... }:
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
  system.stateVersion = "24.11";
  networking.hostName = "iridium";

  users.users.root.initialPassword = "hello";

  imports = [ common-cpu-intel common-gpu-intel ];

  xnet = {
    disk = {
      enable = true;
      device = "/dev/nvme0n1";
    };
    net = {
      sshd.enable = true;
      interface = "enp1s0";
      join = [ "plaza" "kubenet" ];
    };
    nginx.enable = true;
    monitoring.hostGrafana = true;
    gitServer = {
      enable = true;
      gitweb.enable = true;
      keys = lib.splitString "\n" (builtins.readFile gitKeys);
    };
  };
}
