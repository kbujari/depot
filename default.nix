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
    };

  newPkgs = import defaultNixpkgs {
    config = {
      allowUnfree = true;
      allowUnfreeRedistributable = true;
    };

    overlays = [ overlay ];
  };

in
newPkgs.depotPackages
