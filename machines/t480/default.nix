{ ... }: {
  system.stateVersion = "24.05";

  xnet = {
    desktop.enable = true;
    disk = {
      enable = true;
      device = "nvme0n1";
      extraDatasets = {
        "persist/usr" = {
          type = "zfs_fs";
          mountpoint = "/home/k6";
          options.mountpoint = "legacy";
        };
      };
    };
  };

  networking = {
    hostName = "t480";
    useDHCP = false;
    dhcpcd.enable = false;
    nameservers = [ "9.9.9.9" ];
    networkmanager = {
      enable = true;
      dns = "none";
      wifi = {
        powersave = true;
        backend = "iwd";
      };
    };
  };

  systemd.tmpfiles.rules = [
    "d /persist/data/NetworkManager 0750 - - -"
    "L+ /var/lib/NetworkManager - - - - /persist/data/NetworkManager"
  ];
}
