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
    flake.outputs.nixosModules.desktop
    flake.outputs.nixosModules.network
  ];

  nixpkgs.hostPlatform = "x86_64-linux";

  users.users.kle = kle;

  xnet = {
    disk = {
      enable = true;
      device = "/dev/nvme0n1";
    };
  };

  depot.net = {
    v6Token = "::beef";
    sshd.enable = true;
    sshd.publish = true;
  };

  # depot.disk = {
  #   enable = true;
  #   device = "/dev/nvme0n1";
  #   persistHome = true;
  # };

  services.avahi.enable = false;

  networking.hostName = "t1";

  programs = {
    steam.enable = true;
    steam.extraCompatPackages = [ pkgs.proton-ge-bin ];
  };

  fileSystems = {
    "/radon" = {
      device = "radon.local:/radon";
      fsType = "nfs";
      options = [ "noauto" "x-systemd.automount" "x-systemd.idle-timeout=600" "nofail" ];
    };

    "/mnt/gammix" = {
      device = "/dev/disk/by-uuid/bbbb4579-fac9-412e-a831-3034f7d27e04";
      fsType = "ext4";
      options = [ "users" "nofail" "noatime" ];
    };
    "/var" = {
      device = "zroot/local/var";
      fsType = "zfs";
    };
  };

  services = {
    trezord.enable = true;
    guix.enable = true;
    lact.enable = true;
  };

  services.udev.packages = [ pkgs.ddcutil ];
  environment.shellAliases.b = "${pkgs.ddcutil}/bin/ddcutil setvcp 10";
  boot.kernelModules = [ "i2c-dev" ];

  hardware.amdgpu.overdrive.enable = true;

  environment.systemPackages = with pkgs; [
    ddcutil
    prismlauncher
    spotify
    runelite
    bolt-launcher
  ];
}
