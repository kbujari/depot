{ config, ... }:
let
  inherit (config.services) jellyfin;
in
{
  services.jellyfin.enable = true;

  users.groups.media.members = [ jellyfin.user ];

  xnet.persist = [
    {
      path = jellyfin.cacheDir;
      user = jellyfin.user;
      group = jellyfin.group;
      mode = "0750";
    }
    {
      path = jellyfin.dataDir;
      user = jellyfin.user;
      group = jellyfin.group;
      mode = "0750";
    }
    {
      path = jellyfin.configDir;
      user = jellyfin.user;
      group = jellyfin.group;
      mode = "0750";
    }
  ];

  services.nginx.virtualHosts."mov.4kb.net" = {
    locations."/".proxyPass = "http://localhost:8096";
  };
}
