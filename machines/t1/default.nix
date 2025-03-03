{ inputs, depot, pkgs, ... }:

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

  system.stateVersion = "24.11";

  users.users.kle = kle.nixos;

  xnet = {
    desktop.enable = true;
    net = {
      interface = "enp5s0";
      join = [ "plaza" ];
      sshd.enable = true;
    };
    disk = {
      enable = true;
      device = "/dev/nvme0n1";
    };
  };

  networking = {
    hostName = "t1";
  };

  programs = {
    steam.enable = true;
    corectrl = {
      enable = true;
      gpuOverclock.enable = true;
    };
  };

  fileSystems."/mnt/media" = {
    device = "radon:/radon/media";
    fsType = "nfs";
    options = [ "noauto" "x-systemd.automount" "x-systemd.idle-timeout=600" ];
  };

  services.udev.packages = [ pkgs.ddcutil ];
  environment.shellAliases.b = "${pkgs.ddcutil}/bin/ddcutil setvcp 10";

  environment.systemPackages = with pkgs; [
    ddcutil
    prismlauncher
    spotify
  ];
}
