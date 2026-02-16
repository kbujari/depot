{ config, lib, ... }:
let
  cfg = config.depot.net;
  inherit (lib)
    mkOption
    types
    ;

  quad9 = [
    "9.9.9.9#dns.quad9.net"
    "149.112.112.112#dns.quad9.net"
    "2620:fe::fe#dns.quad9.net"
    "2620:fe::9#dns.quad9.net"
  ];

  cloudflare = [
    "1.1.1.1#one.one.one.one"
    "1.0.0.1#one.one.one.one"
    "2606:4700:4700::1111#one.one.one.one"
    "2606:4700:4700::1001#one.one.one.one"
  ];

in
{
  imports = [
    ./sshd.nix
  ];

  options.depot.net = {
    v6Token = mkOption {
      type = types.str;
      default = "eui64";
      description = "Token for global v6 address, defaults to eui64";
    };
  };

  config = {
    # networkd handles this
    networking.useDHCP = false;

    systemd.network.enable = true;
    systemd.network.networks = {
      "10-base" = {
        matchConfig = {
          Name = "*";
          Type = "ether";
        };

        ipv6AcceptRAConfig.Token = cfg.v6Token;

        networkConfig = {
          DHCP = "ipv4";
          UseDomains = true;

          # Enable MDNS resolve/publish over this network
          MulticastDNS = true;
        };
      };
    };

    networking.firewall.allowedUDPPorts = [ 5353 ];

    services.resolved = {
      enable = true;
      settings.Resolve.FallBackDNS = quad9 ++ cloudflare;
    };
  };
}
