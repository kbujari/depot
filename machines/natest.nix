{ flake, modulesPath, perSystem, ... }: {
  imports = [
    flake.outputs.nixosModules.disk
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "24.11";

  environment.systemPackages = [ perSystem.self.partitioner ];
  virtualisation.diskSize = 16384;
}
