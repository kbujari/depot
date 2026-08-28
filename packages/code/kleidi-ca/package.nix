{ lib, haskellPackages, stdenvNoCC, depotPackages, ... }:

let
  inherit (lib) fileset getBin;

  builder = haskellPackages.developPackage {
    root = fileset.toSource {
      root = ./.;
      fileset = fileset.unions [
        ./kleidi-ca.cabal
        ./src
        ./app
      ];
    };
  };

  site = stdenvNoCC.mkDerivation {
    name = "kleidi-ca";
    src = fileset.toSource {
      root = ./.;
      fileset = fileset.unions [
        # ./content
        ./css
        ./templates
        ./images
        ./posts
        ./about.rst
        ./contact.markdown
        ./index.html
      ];
    };

    buildPhase = "${getBin builder}/bin/site rebuild";
    checkPhase = "${getBin builder}/bin/site check";

    installPhase = ''
      mv _site $out
p
      mkdir $out/share
      cp -v ${depotPackages.misc.cv} $out/share/cv.pdf
    '';
  };
in
{ inherit builder site; }
