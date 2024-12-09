{ config, lib, ... }:
let
  cfg = config.xnet.nginx;

  inherit (lib) mkOption mkIf types;
in
{

  options.xnet.nginx = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable optimized nginx.";
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [ 80 443 ];

    services.nginx = {
      enable = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
    };
  };
}
