{ lib, inputs, depot, ... }:
let
  inherit (inputs.nixos-hardware.nixosModules)
    common-cpu-intel
    common-gpu-intel
    ;

  inherit (depot.users.kle)
    gitKeys
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
