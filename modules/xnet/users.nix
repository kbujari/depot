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
    users.mutableUsers = false;

    users.users.kle = mkIf (builtins.elem "kle" cfg.enable) {
      hashedPassword = "$6$R4dDhaftX.vapGMd$.An36hlp3DXfkIC7bPZ0MDPo6Zvpk8JRrhy2LES.lZZj6JDa74oJkcMW3DCsIySvLJxOPXSShos0TpgJ/w0fH/";
      isNormalUser = true;
      createHome = true;
      extraGroups = [ "wheel" "users" "networkmanager" "video" ];
      packages = with pkgs; [
        btop
        curl
        fzf
        git
        jq
        lynx
        neovim
        ranger
        rsync
        sshfs
        tree
        zip
      ];
    };

    programs.ssh.extraConfig = ''
      Host github
        HostName github.com
        User git
        PreferredAuthentications publickey
    '';

    programs.git = {
      config = {
        init = {
          defaultBranch = "master";
        };
        push = {
          default = "upstream";
          autoSetupRemote = true;
        };
        fetch = {
          prune = true;
        };
      };
    };
  };
}
