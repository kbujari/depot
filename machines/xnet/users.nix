{ pkgs, lib, config, ... }:
let
  inherit (builtins)
    elem
    ;

  inherit (lib)
    mkOption
    mkIf
    types
    ;

  cfg = config.xnet.users;

  userEn = user: elem user cfg.enable;

  gitKeys = builtins.fetchurl {
    url = "https://github.com/kbujari.keys";
    sha256 = "0fpa679zkrpx77vangzf3gnidwvmky8ifivn8411xx6albrikaqx";
  };

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
      users.root = {
        initialHashedPassword = "$y$j9T$eGwGb5tZwhk/.K0Lezsx4/$dJ4AODPBo0RBkVoCh1MVZTtkkDRn/C6A/XQIKt2YBNA";
        openssh.authorizedKeys.keys = lib.splitString "\n" (builtins.readFile gitKeys);
      };
      users.kle = mkIf (userEn "kle") {
        initialHashedPassword = "$6$R4dDhaftX.vapGMd$.An36hlp3DXfkIC7bPZ0MDPo6Zvpk8JRrhy2LES.lZZj6JDa74oJkcMW3DCsIySvLJxOPXSShos0TpgJ/w0fH/";
        isNormalUser = true;
        shell = pkgs.fish;
        home = "/persist/usr/kle";
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
          ripgrep
          rsync
          sshfs
          tree
          zip
        ];
        openssh.authorizedKeys.keys = lib.splitString "\n" (builtins.readFile gitKeys);
      };
    };

    disko.devices.zpool.zroot.datasets = { };

    security.sudo = {
      execWheelOnly = true;
      extraConfig = "Defaults lecture = never";
    };

    programs.ssh = {
      knownHosts = {
        "github.com".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
        "gitlab.com".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAfuCHKVTjquxvt6CM6tdG4SLp1Btn/nOeHHE5UOzRdf";
        "git.sr.ht".publicKey = " ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMZvRd4EtM7R+IHVMWmDkVU3VLQTSwQDSAvW0t2Tkj60";
        "pascal.ee.ryerson.ca".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFmWInQNT6EoU1NtUYzTs5jtpfbO/m6yvCckOiEGjvDc";
      };
      extraConfig = ''
        Host github
          HostName github.com
          User git
          PreferredAuthentications publickey

        Host ee
          HostName pascal.ee.ryerson.ca
          User kbujari
      '';
    };

    programs.git = {
      enable = true;
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
