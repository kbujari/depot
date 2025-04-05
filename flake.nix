{
  description = "Personal monorepo";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    disko.url = "github:nix-community/disko/latest";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    nixos-hardware.url = "github:nixos/nixos-hardware/master";
  };

  outputs = { self, nixpkgs, ... } @ inputs:
    let
      inherit (builtins) mapAttrs;

      inherit (nixpkgs) lib;

      systems = [ "x86_64-linux" "aarch64-linux" ];

      inherit (import ./lib/depot-tools.nix { inherit inputs systems lib; })
        importDir
        eachSystem
        systemArgs
        ;

      packages = eachSystem (
        { newScope, ... }:
        mapAttrs (pname: { path, ... }: newScope { inherit pname; } path { })
          (importDir ./packages lib.id)
      );

      nixosModules = importDir ./modules
        (mapAttrs (_: { path, ... }: path));

      nixosConfigurations = importDir ./machines (
        entries:
        let
          flake = self;

          defaultModule = { config, ... }:
            let
              perSystemArg = system: {
                _module.args.perSystem = systemArgs.${system}.perSystem;
              };
            in
            {
              imports = [ (perSystemArg config.nixpkgs.hostPlatform.system) ];
            };

          buildNixOS = hostName: entry:
            lib.nixosSystem {
              modules = [
                defaultModule
                entry.path
                nixosModules.xnet
              ];
              specialArgs = { inherit inputs flake hostName; };
            };
        in
        mapAttrs buildNixOS entries
      );
    in
    { inherit packages nixosModules nixosConfigurations; };
}
