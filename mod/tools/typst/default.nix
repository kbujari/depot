{ pkgs, ... }:
let
  version = "0.0.0";

  depotPackages = pkgs.stdenvNoCC.mkDerivation {
    pname = "depot-typst-packages";
    inherit version;
    src = ./packages;
    phases = [ "installPhase" ];

    installPhase = ''
      for pkg in $src/*; do
        name=$(basename $pkg)
        mkdir -p $out/share/typst/packages/depot/$name/${version}
        cp -rv $pkg/* $out/share/typst/packages/depot/$name/${version}/
      done
    '';
  };
in
{
  inherit depotPackages;

  writeEnv = pkgs.mkShellNoCC {
    packages = [
      pkgs.typst
      pkgs.typstyle
      pkgs.tinymist
      depotPackages
    ];

    shellHook = "alias typst='export XDG_DATA_HOME=${depotPackages}/share:$XDG_DATA_HOME'";
  };
}
