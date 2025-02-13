{ pkgs, depot, ... }:
let
  inherit (builtins)
    attrValues
    ;

  inherit (depot.tools)
    perf-flamegraph
    ;


  gitKeys = builtins.fetchurl {
    url = "https://github.com/kbujari.keys";
    sha256 = "1kskbiyqvjz1wsmcrgh9v0iryf33y70zk503z0m96wmzdjllmc94";
  };

  keys = {
    t480 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEOw8YEbHsKy38JHp9W1wcxxZgWCDgnabOXccZUN5ddd";
  };
in
{
  inherit keys;
  inherit gitKeys;

  nixos = {
    initialHashedPassword = "$6$R4dDhaftX.vapGMd$.An36hlp3DXfkIC7bPZ0MDPo6Zvpk8JRrhy2LES.lZZj6JDa74oJkcMW3DCsIySvLJxOPXSShos0TpgJ/w0fH/";
    isNormalUser = true;
    shell = pkgs.fish;
    home = "/persist/usr/kle";
    createHome = true;
    extraGroups = [ "wheel" "users" "networkmanager" "video" "corectrl" ];
    packages = with pkgs; [
      # utilities
      btop
      curl
      fzf
      jq
      lynx
      neovim
      perf-flamegraph
      ranger
      ripgrep
      rsync
      sshfs
      tree
      zip

      # nix debugging
      nixd
      nixpkgs-fmt
    ];

    openssh.authorizedKeys.keys = attrValues keys;
  };
}
