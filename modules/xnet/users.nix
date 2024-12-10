{ pkgs, lib, config, ... }:
let
  cfg = config.xnet.users;
  inherit (lib) mkOption mkIf types;
in
{

  options.xnet.users = {
    enable = mkOption {
      type = types.listOf (types.enum [ "kle" ]);
      default = [ ];
      description = "Users to enable.";
    };
  };

  config = {
    users = {
      mutableUsers = false;
      users.kle = mkIf (builtins.elem "kle" cfg.enable) {
        hashedPassword = "$6$R4dDhaftX.vapGMd$.An36hlp3DXfkIC7bPZ0MDPo6Zvpk8JRrhy2LES.lZZj6JDa74oJkcMW3DCsIySvLJxOPXSShos0TpgJ/w0fH/";
        isNormalUser = true;
        createHome = true;
        extraGroups = [ "wheel" "users" "networkmanager" "video" ];
        packages = with pkgs; [
          btop
          curl
          fzf
          jq
          lynx
          neovim
          ranger
          rsync
          sshfs
          tree
          zip
        ];
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP7T2uWJFUu8aFZZgQusGKyEMocb2pKbHLDad2eIJus9"
        ];
      };
    };

    security.sudo = {
      execWheelOnly = true;
      extraConfig = "Defaults lecture = never";
    };

    programs.ssh = {
      knownHosts = {
        "github.com".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
      };
      extraConfig = ''
        Host github
          HostName github.com
          User git
          PreferredAuthentications publickey
      '';
    };

    programs.git = {
      config = {
        init.defaultBranch = "master";
        fetch.prune = true;
        core.excludesFile = pkgs.writeText "gitignore" ''
          # dev shell caching
          .direnv/
          .envrc
        '';
        push.default = "upstream";
        push.autoSetupRemote = true;
      };
    };
  };
}
