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

    services.cgit.main = {
      enable = true;
      scanPath = config.xnet.gitServer.path;
      package = pkgs.cgit-pink;
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
        readme=:readme
        readme=:readme.md
        readme=:readme.txt
        readme=:README
        readme=:README.md
        readme=:README.txt
      '';
      settings = {
        about-filter = "${pkgs.cgit-pink}/lib/cgit/filters/about-formatting.sh";
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

    # required for rendering markdown readme
    environment.systemPackages = with pkgs; [
      python312
      python312Packages.markdown
    ];

    # services.nginx.virtualHosts."${cfg.gitweb.hostName}" = {
    #   useACMEHost = "4kb.net";
    #   addSSL = true;
    # };
  };
}
