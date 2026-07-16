{
  flake,
  pkgs,
  config,
  ...
}:
{
  nixpkgs.hostPlatform.system = "x86_64-linux";
  system.stateVersion = "25.05";
  networking.hostName = "iridium";

  imports = [
    flake.outputs.nixosModules.intel
    flake.outputs.nixosModules.network
  ];

  depot.net = {
    v6Token = "::0102";
    sshd.enable = true;
    sshd.publish = true;
  };

  services.nginx.virtualHosts."kleidi.ca" = {
    acmeRoot = null;
    useACMEHost = "kleidi.ca";
    addSSL = true;
    root = pkgs.depot.web.site;
  };

  security.acme = {
    acceptTerms = true;

    defaults = {
      email = "certs@4kb.net";
      dnsProvider = "porkbun";
      environmentFile = "/persist/porkbun";
      group = config.services.nginx.group;
    };

    certs."kleidi.ca".extraDomainNames = [ "*.kleidi.ca" ];
    certs."4kb.net".extraDomainNames = [ "*.4kb.net" ];
  };

  services.redlib.enable = true;
  services.nginx.virtualHosts."redlib.4kb.net" = {
    acmeRoot = null;
    useACMEHost = "4kb.net";
    forceSSL = true;
    locations."/" = {
      extraConfig = "proxy_http_version 1.1;";
      proxyPass = "http://${config.services.redlib.address}:${toString config.services.redlib.port}";
    };
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
