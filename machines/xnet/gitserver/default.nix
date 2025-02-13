{ config, lib, pkgs, ... }:
let
  cfg = config.xnet.gitServer;
  inherit (lib) mkOption mkIf types;
in
{
  imports = [ ./gitweb.nix ];

  options.xnet.gitServer = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Serve git repos over SSH.";
    };

    path = mkOption {
      type = types.path;
      default = "/persist/repo/git";
      description = "Directory where repos will be stored.";
    };
  };

  config = mkIf cfg.enable {
    users.users.git = {
      group = "git";
      initialPassword = "";
      isSystemUser = true;
      home = cfg.path;
      homeMode = "755";
      createHome = true;
      shell = "${pkgs.git}/bin/git-shell";
      openssh.authorizedKeys.keys = config.xnet.pubKeys;
    };

    users.groups.git = { };

    programs.git = {
      enable = true;
      config = {
        init = {
          defaultBranch = "master";
        };
        safe = {
          directory = "*";
        };
      };
    };
  };
}
