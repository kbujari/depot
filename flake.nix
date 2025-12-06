{
  description = "Personal monorepo";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    disko.url = "github:nix-community/disko/latest";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    nixos-hardware.url = "github:nixos/nixos-hardware/master";
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      inherit (nixpkgs) lib;

      systems = lib.intersectLists lib.systems.flakeExposed lib.platforms.linux;

      forAllSystems = lib.genAttrs systems;
      nixpkgsFor = forAllSystems (
        system:
        import inputs.nixpkgs {
          inherit system;
          overlays = [ overlays.default ];
        }
      );

      inherit (import ./lib/depot-tools.nix { inherit inputs systems lib; })
        importDir
        systemArgs
        ;

      overlays.default =
        final: _:
        let
          depot = lib.filesystem.packagesFromDirectoryRecursive {
            callPackage = lib.callPackageWith (final // { inherit depot; });
            directory = ./packages;
          };
        in
        {
          inherit depot;
        };

      nixosModules = importDir ./modules (builtins.mapAttrs (_: { path, ... }: path));

      nixosConfigurations = importDir ./machines (
        entries:
        let
          flake = self;

          defaultModule =
            { config, ... }:
            let
              perSystemArg = system: {
                _module.args.perSystem = systemArgs.${system}.perSystem;
              };
            in
            {
              imports = [ (perSystemArg config.nixpkgs.hostPlatform.system) ];
            };

          buildNixOS =
            hostName: entry:
            lib.nixosSystem {
              modules = [
                defaultModule
                entry.path
                nixosModules.xnet
              ];
              specialArgs = { inherit inputs flake hostName; };
            };
        in
        builtins.mapAttrs buildNixOS entries
      );
    in
    {
      inherit nixosModules nixosConfigurations;

      formatter = forAllSystems (system: nixpkgsFor.${system}.nixfmt-rfc-style);
      packages = forAllSystems (
        system:
        let
          inherit (nixpkgsFor.${system}) depot;
        in
        {
          inherit (depot.misc) cv;
          inherit (depot.web) site;
          inherit (depot)
            randpass
            run-image
          ;
        }
      );
    };
}
