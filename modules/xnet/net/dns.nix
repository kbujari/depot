{ lib, ... }:
let
  inherit (lib)
    mkDefault
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

  networking.nameservers = mkDefault quad9;

  services.resolved = {
    enable = true;
    llmnr = "false";
    dnssec = "false";
    dnsovertls = mkDefault "opportunistic";
    fallbackDns = quad9 ++ cloudflare;
    extraConfig = ''
      MulticastDNS=yes
    '';
  };

  # Allow mDNS resolution
  networking.firewall.allowedTCPPorts = [ 5353 ];
}
