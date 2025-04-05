{ inputs, flake, pkgs, perSystem, ... }:

let
  inherit (inputs.nixos-hardware.nixosModules)
    common-cpu-amd
    common-gpu-amd
    ;

  inherit (import flake.outputs.nixosModules.users { inherit perSystem pkgs; })
    kle;
in
{
  imports = [
    common-cpu-amd
    common-gpu-amd
    flake.outputs.nixosModules.disk
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "24.11";

  users.users.kle = kle;

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

  networking.hostName = "t1";

  programs = {
    steam.enable = true;
    steam.extraCompatPackages = [ pkgs.proton-ge-bin ];
    corectrl = {
      enable = true;
      gpuOverclock.enable = true;
    };
  };

  fileSystems = {
    "/mnt/media" = {
      device = "radon:/radon/media";
      fsType = "nfs";
      options = [ "noauto" "x-systemd.automount" "x-systemd.idle-timeout=600" ];
    };

    "/mnt/gammix" = {
      device = "/dev/disk/by-uuid/bbbb4579-fac9-412e-a831-3034f7d27e04";
      fsType = "ext4";
      options = [ "users" "nofail" "noatime" ];
    };
  };

  services.udev.packages = [ pkgs.ddcutil ];
  environment.shellAliases.b = "${pkgs.ddcutil}/bin/ddcutil setvcp 10";
  boot.kernelModules = [ "i2c-dev" ];

  environment.systemPackages = with pkgs; [
    ddcutil
    prismlauncher
    spotify
  ];
}
