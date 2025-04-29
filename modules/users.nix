{ pkgs, perSystem, ... }:
let
  inherit (builtins)
    attrValues;

  inherit (perSystem.self)
    perf-flamegraph
    ;

  keys = {
    t480 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEOw8YEbHsKy38JHp9W1wcxxZgWCDgnabOXccZUN5ddd";
    t1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP7T2uWJFUu8aFZZgQusGKyEMocb2pKbHLDad2eIJus9";
  };
in
{
  kle = {
    initialHashedPassword = "$6$R4dDhaftX.vapGMd$.An36hlp3DXfkIC7bPZ0MDPo6Zvpk8JRrhy2LES.lZZj6JDa74oJkcMW3DCsIySvLJxOPXSShos0TpgJ/w0fH/";
    isNormalUser = true;
    shell = pkgs.fish;
    home = "/persist/usr/kle";
    createHome = true;
    extraGroups = [ "wheel" "users" "networkmanager" "video" "corectrl" ];
    packages = with pkgs; [
      btop
      curl
      fzf
      guvcview
      jq
      jujutsu
      lynx
      neovim
      helix
      perf-flamegraph
      ranger
      ripgrep
      rsync
      sshfs
      tree
      zip

      emacs-pgtk

      # nix debugging
      nil
      nixpkgs-fmt
    ];

    openssh.authorizedKeys.keys = attrValues keys;
  };
}
