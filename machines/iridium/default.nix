{ inputs, lib, ... }:
let
  gitKeys = builtins.fetchurl {
    url = "https://github.com/kbujari.keys";
    sha256 = "0fpa679zkrpx77vangzf3gnidwvmky8ifivn8411xx6albrikaqx";
  };
in
{
  system.stateVersion = "24.11";

  users.mutableUsers = false;
  users.users.root = {
    initialPassword = "test";
  };

  xnet = {
    disk = {
      enable = true;
      device = "/dev/nvme0n1";
    };
    net = {
      sshd.enable = true;
    };
    users.enable = [ "kle" ];
    gitServer = {
      enable = true;
      gitweb.enable = true;
      keys = lib.splitString "\n" (builtins.readFile gitKeys);
    };
  };

  nix.registry.nixpkgs.flake = inputs.nixpkgs;
}
