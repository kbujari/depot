{ inputs, ... }:
let
  inherit (inputs.nixos-hardware.nixosModules)
    common-cpu-intel
    common-gpu-intel
    ;
in
{
  system.stateVersion = "25.05";
  networking.hostName = "iridium";

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
    };
  };
}
