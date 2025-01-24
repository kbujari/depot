{ config, ... }:
let
  inherit (builtins)
    map
    ;

  inherit (config.services.prometheus) exporters;
in
{
  imports = [ ./grafana.nix ];


  config = {
    services.prometheus = {
      enable = config.xnet.monitoring.hostGrafana;
      globalConfig.scrape_interval = "1m";

      exporters = {
        node = {
          enable = true;
          openFirewall = true;
          enabledCollectors = [ "processes" "systemd" ];
        };

        # systemd = {
        #   enable = true;
        #   openFirewall = true;
        #   extraFlags = [
        #     "--systemd.collector.enable-ip-accounting"
        #     "--systemd.collector.enable-restart-count"
        #   ];
        # };

        smartctl = {
          enable = true;
          openFirewall = true;
        };
      };

      scrapeConfigs =
        let
          hosts = [ "iridium" "radon" ];
        in
        [{
          job_name = "node";
          static_configs = [{
            targets = map (h: "${h}:${toString exporters.node.port}") hosts;
          }];
        }
          {
            job_name = "smartctl";
            static_configs = [{
              targets = map (h: "${h}:${toString exporters.smartctl.port}") hosts;
            }];
          }];
    };
  };
}
