{
  modulesPath,
  pkgs,
  config,
  lib,
  flake,
  ...
}:
{
  imports = [
    # (modulesPath + "/installer/cd-dvd/iso-image.nix")
    # (modulesPath + "/installer/cd-dvd/channel.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    flake.outputs.nixosModules.disk
  ];

  nixpkgs.hostPlatform.system = "x86_64-linux";
  depot.disk = {
    enable = true;
  };

  users.users.root.initialPassword = "hello";
}
