{ inputs, flake, ... }:
let
  inherit (inputs.nixos-hardware.nixosModules)
    common-cpu-intel
    common-gpu-intel
    ;
in
{
  nixpkgs.hostPlatform.system = "x86_64-linux";
  system.stateVersion = "25.05";
  networking.hostName = "iridium";

  imports = [
    common-cpu-intel
    common-gpu-intel
    flake.outputs.nixosModules.network
  ];

  depot.net = {
    sshd.enable = true;
    sshd.publish = true;
  };

  xnet = {
    disk = {
      enable = true;
      device = "/dev/nvme0n1";
    };
    nginx.enable = true;
    gitServer = {
      enable = true;
      gitweb.enable = true;
    };
  };
}
