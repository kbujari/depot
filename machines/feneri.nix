{ flake, modulesPath, ... }:

{
  imports = [
    flake.outputs.nixosModules.disk
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  nixpkgs.hostPlatform.system = "x86_64-linux";

  depot.disk = {
    enable = true;
    # device = "/dev/vda";
  };

  services.getty.autologinUser = "root";

  networking.hostName = "feneri";
}
