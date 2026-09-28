let
  lock = builtins.readFile ./flake.lock |> builtins.fromJSON;

  defaultNixpkgs = builtins.fetchGit {
    url = "https://github.com/NixOS/nixpkgs";
    shallow = true;
    inherit (lock.nodes.nixpkgs.locked) rev;
    inherit (lock.nodes.nixpkgs.original) ref;
  };
in
{
  pkgs ? import defaultNixpkgs { },
  localSystem ? builtins.currentSystem,
  crossSystem ? null,
  ...
}:

let
  inherit (pkgs) lib;

  inherit (lib)
    packagesFromDirectoryRecursive
    ;

  importDir = import lib/importDir.nix { inherit lib; };

  overlay =
    final: _:
    let
      depotPackages = packagesFromDirectoryRecursive {
        callPackage = lib.callPackageWith (final // { inherit depotPackages; });
        directory = ./packages;
      };
    in
    {
      inherit depotPackages;
      depot = depotPackages;
    };

  newPkgs = import defaultNixpkgs {
    config = {
      allowUnfree = true;
      allowUnfreeRedistributable = true;
    };

    overlays = [ overlay ];
  };

  nixosModules = importDir ./modules (builtins.mapAttrs (_: { path, ... }: path));

  machines = importDir ./machines (
    entries:
    let
      defaultModule = { config, ... }: {
        nixpkgs.overlays = [ overlay ];
        system.stateVersion = lib.mkDefault config.system.nixos.release;
      };

      buildNixOS =
        hostName: entry:
        import (pkgs.path + "/nixos/lib/eval-config.nix") {
          modules = [
            defaultModule
            entry.path
            nixosModules.xnet
            nixosModules.disk
            # nixosModules.network
            nixosModules.sshd
          ];
        };
    in
    builtins.mapAttrs buildNixOS entries
  );

in
{
  pkgs = newPkgs;
  inherit (newPkgs) depotPackages;
  inherit machines;
}
