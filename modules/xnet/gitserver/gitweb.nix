{ config, lib, pkgs, ... }:
let
  cfg = config.xnet.gitServer.gitweb;
  inherit (lib) mkOption mkIf types;
in
{
  options.xnet.gitServer.gitweb = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable web interface to git repos.";
    };

    hostName = mkOption {
      type = types.str;
      default = "src.web.4kb.net";
      description = "Hostname the webUI is served from.";
    };
  };

  config = mkIf cfg.enable {
    xnet.nginx.enable = true;

    users.users.nginx.extraGroups = [ "git" ];
    services.cgit.main = {
      enable = true;
      scanPath = config.xnet.gitServer.path;
      gitHttpBackend.checkExportOkFiles = false;
      nginx = {
        virtualHost = cfg.hostName;
        location = "/";
      };
      extraConfig = ''
        mimetype.gif=image/gif
        mimetype.html=text/html
        mimetype.jpeg=image/jpeg
        mimetype.jpg=image/jpeg
        mimetype.pdf=application/pdf
        mimetype.png=image/png
        mimetype.svg=image/svg+xml
        readme=master:README
      '';
      settings = {
        about-filter = "${pkgs.cgit}/lib/cgit/filters/about-formatting.sh";
        source-filter = "${pkgs.cgit}/lib/cgit/filters/syntax-highlighting.py";
        clone-url = "https://${cfg.hostName}/$CGIT_REPO_URL git@${cfg.hostName}:$CGIT_REPO_URL";
        enable-commit-graph = true;
        enable-http-clone = false;
        enable-index-links = true;
        enable-remote-branches = true;
        remove-suffix = true;
        robots = "noindex, nofollow";
        root-desc = "What I cannot create, I do not understand";
        root-title = cfg.hostName;
        section-from-path = true;
        snapshots = "tar.gz tar.bz2 zip";
      };
    };

    services.nginx.virtualHosts."${cfg.hostName}" = {
      useACMEHost = "4kb.net";
      forceSSL = true;

      locations."/robots.txt".return = "200 \"User-agent: *\nDisallow: /\n\"";
    };
  };
}
