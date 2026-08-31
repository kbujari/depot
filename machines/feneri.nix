{ flake, modulesPath, ... }:

{
  imports = [
    flake.outputs.nixosModules.disk
    flake.outputs.nixosModules.network
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  nixpkgs.hostPlatform.system = "x86_64-linux";

  depot.disk = {
    enable = true;
    # device = "/dev/vda";
  };

  depot.net = {
    sshd.enable = true;
  };

  services.getty.autologinUser = "root";

  networking.hostName = "feneri";
}
