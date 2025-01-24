{ inputs, ... }:

let
  inherit (inputs.nixos-hardware.nixosModules)
    common-cpu-amd
    common-gpu-amd
    ;
in
{
  imports = [
    common-cpu-amd
    common-gpu-amd
  ];

  system.stateVersion = "24.11";

  xnet = {
    desktop.enable = true;
    users.enable = [ "kle" ];
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
