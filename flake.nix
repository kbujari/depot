{
  description = "Personal monorepo";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    disko.url = "github:nix-community/disko/v1.6.1";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    nixos-hardware.url = "github:nixos/nixos-hardware/master";

    # Rust projects
    naersk.url = "github:nix-community/naersk";
    naersk.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, ... } @ inputs:
    let
      inherit (builtins)
        attrNames
        listToAttrs
        map
        readDir
        ;

      inherit (nixpkgs) lib;

      inherit (nixpkgs.lib)
        mapAttrs
        nixosSystem
        ;

      systems = [ "x86_64-linux" "aarch64-linux" ];

      inherit (import ./lib/depot-tools.nix { inherit inputs systems lib; })
        importDir
        eachSystem
        systemArgs
        ;

      packages = eachSystem (
        { newScope, ... }:
        mapAttrs (pname: { path, ... }: newScope { inherit pname; } path { })
          (importDir ./packages)
      );

      publisherArgs = {
        flake = self;
        inherit inputs;
      };

      expectsPublisherArgs =
        module:
        builtins.isFunction module
        && builtins.all (arg: builtins.elem arg (builtins.attrNames publisherArgs)) (
          builtins.attrNames (builtins.functionArgs module)
        );

      injectPublisherArgs =
        modulePath:
        let
          module = import modulePath;
        in
        if expectsPublisherArgs module then
          lib.setDefaultModuleLocation modulePath (module publisherArgs)
        else
          modulePath;

      nixosModules = mapAttrs (_: moduleDir: injectPublisherArgs moduleDir)
        (mapAttrs (_: { path, ... }: path) (importDir ./modules));
    in
    {
      inherit packages nixosModules;

      nixosConfigurations = listToAttrs (
        map
          (name: {
            inherit name;
            value = nixosSystem rec {
              system = "x86_64-linux";
              specialArgs = {
                inherit inputs;
                inherit (self) outputs;
                inherit (systemArgs.${system}) flake perSystem;
              };
              modules = [
                # Machine's specific configuration
                ./machines/${name}

                # Implicitly import xnet
                self.nixosModules.xnet

                # Global module
                ({ inputs, ... }: {

                  # Set system nixpkgs to flake input
                  nix.registry = {
                    nixpkgs.flake = inputs.nixpkgs;
                    depot.flake = self;
                  };
                })
              ];
            };
          })
          (attrNames (readDir ./machines))
      );
    };
}
