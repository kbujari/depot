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

  xnet.disk = {
    enable = true;
    device = "/dev/nvme0n1";
  };

  depot.net = {
    v6Token = "::beef";
    sshd.enable = true;
    sshd.publish = true;
  };

  # depot.disk.enable = true;

  services.avahi.enable = false;

  networking.hostName = "t1";

  programs = {
    steam = {
      enable = true;
      extraCompatPackages = [ pkgs.proton-ge-bin ];
    };
  };

  fileSystems = {
    "/var" = {
      device = "zroot/local/var";
      fsType = "zfs";
    };

    "/gnu" = {
      device = "zroot/local/gnu";
      fsType = "zfs";
    };
  };

  services = {
    trezord.enable = true;
    guix.enable = true;
    # lact.enable = true;
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;

    settings.General = {
      Experimental = true;
      # FastConnectable = true;
    };

    settings.Policy = {
      AutoEnable = true;
    };
  };

  services.blueman.enable = true;

  # services.udev.packages = [ pkgs.ddcutil ];
  # environment.shellAliases.b = "${pkgs.ddcutil}/bin/ddcutil setvcp 10";
  # boot.kernelModules = [ "i2c-dev" "ddcci-backlight" ];

  # boot.extraModulePackages = [ config.boot.kernelPackages.ddcci-driver ];
  # hardware.i2c.enable = true;

  environment.systemPackages = with pkgs; [
    # depot.misc.northstar-proton
    ddcutil
    prismlauncher
    spotify
    runelite
    bolt-launcher
  ];

  containers.hello = {
    autoStart = true;
    ephemeral = true;
    privateUsers = "pick";
    privateNetwork = true;
    hostBridge = "plaza";
    config = { ... }: {
      services.httpd = {
        enable = true;
        adminAddr = "wow@wxample.org";
      };

      networking.firewall.allowedTCPPorts = [ 80 ];
    };
  };

  systemd.network = {
    netdevs."20-plaza".netdevConfig = {
      Kind = "bridge";
      Name = "plaza";
    };

    networks."30-virtuals" = {
      matchConfig.Name = "vb-*";
      networkConfig.Bridge = "plaza";
    };

    networks."20-plaza" = {
      matchConfig.Name = "plaza";
      linkConfig.RequiredForOnline = "no";

      networkConfig = {
        LinkLocalAddressing = "ipv6";
        ConfigureWithoutCarrier = "yes";
      };
    };
  };
}
