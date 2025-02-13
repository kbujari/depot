{
  description = "Personal monorepo";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";

    disko.url = "github:nix-community/disko/v1.6.1";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    nixos-hardware.url = "github:nixos/nixos-hardware/master";

    # Rust projects
    naersk.url = "github:nix-community/naersk";
    naersk.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, ... } @ inputs:
    let
      inherit (builtins)
        attrNames
        filter
        listToAttrs
        map
        readDir
        ;

      inherit (nixpkgs.lib)
        nixosSystem
        ;

      readTree = import ./mod/nix/readTree { };

      # Recursively converts subdirectories under ./mod into an attrset
      # that can be passed to other parts of the depot.
      readDepot = depotArgs: readTree {
        args = depotArgs;
        path = ./mod;
      };

      # Named arguments to be made available to any nix expression in
      # the depot module.
      depot = readTree.fix (self: readDepot {
        depot = self;

        inherit inputs;

        # x86_64-linux is hardcoded as the package arch only for the
        # mod directory. This workaround keeps the flake pure,
        # at the expense of only supporting one system. This can
        # be circumvented by retrieving the system during evaluation,
        # but flakes disallow this by design.
        #
        # This monorepo currently depends on functionality from flakes,
        # but this may change in the future, perhaps shifting to an
        # impure base with certain packages exposed from the flake in a
        # pure way.
        #
        # In practice, this means that any configuration or package
        # exposed from the depot flake that makes use of internal
        # derivations is limited to x86_64-linux. For now this is fine,
        # but ideally any architecture supported by nix should be
        # allowed to evaluate projects hosted here.
        pkgs = nixpkgs.legacyPackages."x86_64-linux";

        # Expose lib attribute to modules.
        lib = nixpkgs.lib;
      });

      machines = filter (m: m != "xnet")
        (attrNames (readDir ./machines));
    in
    {
      inherit depot;

      nixosModules.xnet.imports =
        [ ./machines/xnet inputs.disko.nixosModules.disko ];

      nixosConfigurations = listToAttrs (
        map
          (name: {
            inherit name;
            value = nixosSystem {
              system = "x86_64-linux";
              specialArgs = { inherit inputs depot; };
              modules = [
                # Machine's specific configuration
                ./machines/${name}

                # Implicitly import xnet
                self.nixosModules.xnet

                # Global module
                ({ inputs, ... }: {

                  # Set system nixpkgs to flake input
                  nix.registry.nixpkgs.flake = inputs.nixpkgs;
                })
              ];
            };
          })
          machines);
    };
}
