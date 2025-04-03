{ config, pkgs, lib, ... }:
let
  inherit (lib) mkOption mkIf types;

  inherit (config.xnet.monitoring)
    hostGrafana
    ;
in
{
  options.xnet.monitoring = {
    hostGrafana = mkOption {
      type = types.bool;
      default = false;
      description = "Scrape hosts and host the data.";
    };
  };

  config = mkIf hostGrafana {
    services.grafana.provision = {
      enable = true;
      datasources.settings.datasources = [{
        name = "Prometheus";
        type = "prometheus";
        url = "http://localhost:9090";
        access = "proxy";
        editable = false;
      }];

      dashboards.settings.providers = [{
        name = "Fetched Dashboards";
        options.path = "/etc/grafana/dashboards";
      }];
    };

    environment.etc = {
      "grafana/dashboards/node-exporter.json" = {
        user = "grafana";
        group = "grafana";
        source = pkgs.fetchurl {
          url = "https://grafana.com/api/dashboards/1860/revisions/37/download";
          hash = "sha256-1DE1aaanRHHeCOMWDGdOS1wBXxOF84UXAjJzT5Ek6mM=";
        };
      };
      "grafana/dashboards/smartctl-exporter.json" = {
        user = "grafana";
        group = "grafana";
        source = ./grafana.nix;
        # source = pkgs.fetchurl {
        #   url = "https://grafana.com/api/dashboards/22604/revisions/2/download";
        #   hash = "sha256-ci8WE23fZ+ltEKFoUdNNVXsUIV0jqtas79ia2lYIo88=";
        # };
      };
    };

    services.grafana = {
      enable = true;
      settings.server = {
        domain = "grafana.plaza.4kb.net";
        protocol = "socket";
      };
      settings."auth.anonymous" = {
        enabled = true;
        org_role = "Admin";
      };
    };

    users.groups.grafana.members = [ "nginx" ];
    systemd.services.nginx.serviceConfig.ProtectHome = false;

    services.nginx.virtualHosts."${config.services.grafana.settings.server.domain}" = {
      # useACMEHost = "4kb.net";
      # addSSL = true;
      locations."/" = {
        proxyPass = "http://unix:/${toString config.services.grafana.settings.server.socket}";
      };
    };
  };
}
