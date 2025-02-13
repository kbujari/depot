{ ... }: {
  services.resolved.enable = false;

  services.unbound = {
    enable = true;
    settings.server = {
      interface = [ "127.0.0.1" ];
      access-control = [
        "0.0.0.0/0 refuse"
        "127.0.0.0/8 allow"
      ];

      private-domain = [ ];
      private-address = [ ];

      harden-glue = true;
      harden-dnssec-stripped = true;
      use-caps-for-id = false;
      prefetch = true;
      edns-buffer-size = 1232;
      hide-identity = true;
      hide-version = true;
      tls-system-cert = true;
    };

    settings.forward-zone = [{
      name = ".";
      forward-tls-upstream = true;
      forward-addr = [
        "9.9.9.9#dns.quad9.net"
        "149.112.112.112#dns.quad9.net"
      ];
    }];
  };

  networking = {
    nameservers = [ "::1" ];
  };
}
