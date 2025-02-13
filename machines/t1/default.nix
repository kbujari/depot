{ inputs, depot, ... }:

let
  inherit (inputs.nixos-hardware.nixosModules)
    common-cpu-amd
    common-gpu-amd
    ;

  inherit (depot.users) kle;
in
{
  imports = [
    common-cpu-amd
    common-gpu-amd
  ];

  programs.corectrl = {
    enable = true;
    gpuOverclock.enable = true;
  };


  system.stateVersion = "24.11";

  users.users.kle = kle.nixos;

  xnet = {
    desktop.enable = true;
    net.join = [ "plaza" ];
    disk = {
      enable = true;
      device = "/dev/nvme0n1";
    };
  };

  networking = {
    hostName = "t1";
  };

  # override default from xnet
  programs.light.enable = false;
}
