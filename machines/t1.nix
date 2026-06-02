{
  flake,
  pkgs,
  perSystem,
  ...
}:

let
  inherit (import flake.outputs.nixosModules.users { inherit perSystem pkgs; })
    kle
    ;
in
{
  imports = [
    flake.outputs.nixosModules.disk
    flake.outputs.nixosModules.desktop
    flake.outputs.nixosModules.network
  ];

  hardware = {
    cpu.amd.updateMicrocode = true;
    enableRedistributableFirmware = true;
    amdgpu = {
      initrd.enable = true;
      overdrive.enable = true;
    };

    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };

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


  environment.systemPackages = with pkgs; [
    ddcutil
    prismlauncher
    spotify
    runelite
    bolt-launcher
  ];
}
