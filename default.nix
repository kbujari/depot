let
  defaultNixpkgs = builtins.fetchGit {
    url = "https://github.com/NixOS/nixpkgs";
    ref = "nixos-unstable";
    3rev = "9ae611a455b90cf061d8f332b977e387bda8e1ca";
    shallow = true;
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
