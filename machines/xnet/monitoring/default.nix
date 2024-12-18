{ config, ... }:
let
  inherit (config.networking) hostName;
  inherit (config.services.prometheus) exporters;
in
{
  imports = [ ./grafana.nix ./prometheus.nix ];

  exporters = {
    node = {
      enable = true;
      enabledCollectors = [ "processes" "systemd" ];
    };

    systemd = {
      enable = true;
      extraFlags = [
        "--systemd.collector.enable-ip-accounting"
        "--systemd.collector.enable-restart-count"
      ];
    };
  };

  services.prometheus.scrapeConfigs = [
    {
      job_name = "node";
      static_configs = [{
        targets = [ "${hostName}:${toString exporters.node.port}" ];
      }];
    }
    {
      job_name = "systemd";
      static_configs = [{
        targets = [ "${hostName}:${toString exporters.systemd.port}" ];
      }];
    }
  ];
}
