{ pkgs, lib, config, ... }:
let
  inherit (builtins)
    fetchurl
    filter
    readFile
    ;

  inherit (lib)
    mkDefault
    mkOption
    types
    splitString
    ;

  gitKeys = fetchurl {
    url = "https://github.com/kbujari.keys";
    sha256 = "1kskbiyqvjz1wsmcrgh9v0iryf33y70zk503z0m96wmzdjllmc94";
  };

in
{
  imports = [
    ./disk.nix
    ./nginx.nix
    ./persist.nix
    ./net
    ./desktop
    ./gitserver
    ./monitoring
  ];

  options.xnet = {
    pubKeys = mkOption {
      type = types.listOf types.str;
      default = filter (s: s != "")
        (splitString "\n" (readFile gitKeys));
    };
  };

  config = {
    i18n.defaultLocale = mkDefault "en_US.UTF-8";
    time.timeZone = mkDefault "America/Toronto";

    nix = {
      settings = {
        auto-optimise-store = true;
        experimental-features = [ "nix-command" "flakes" ];
        warn-dirty = false;

        # timeout fast from binary cache
        connect-timeout = 5;
      };
      gc = {
        automatic = true;
        options = mkDefault "--delete-older-than 30d";
      };
    };

    documentation = {
      doc.enable = mkDefault false;
      info.enable = mkDefault false;
    };

    users.mutableUsers = false;
    users.users.root = {
      openssh.authorizedKeys.keys = config.xnet.pubKeys;
      initialPassword = "hello";
    };

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
