{
  description = "Personal monorepo";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    disko.url = "github:nix-community/disko/v1.6.1";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { flake-parts, ... } @ inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" ];

      imports = [
        ./machines/flake-module.nix
        ./modules/flake-module.nix
      ];

      perSystem = { pkgs, inputs', ... }: {
        formatter = pkgs.nixpkgs-fmt;

        apps.install = {
          type = "app";
          program = inputs'.disko.packages.disko-install;
        };
      };
    };
}
