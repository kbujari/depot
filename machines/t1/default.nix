{ ... }: {
  system.stateVersion = "24.11";

  xnet = {
    desktop.enable = true;
    users.enable = [ "kle" ];
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
