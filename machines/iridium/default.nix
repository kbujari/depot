{ inputs, lib, ... }: {
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
      keys = builtins.filter (x: x != "")
        (lib.strings.splitString "\n" (builtins.readFile inputs.sshKeys));
    };
  };

  nix.registry.nixpkgs.flake = inputs.nixpkgs;
}
