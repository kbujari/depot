{
  lib,
  zola,
  depot,
  stdenvNoCC,
  ...
}:

let
  inherit (lib) fileset;
in
stdenvNoCC.mkDerivation {
  name = "megasite";
  src = fileset.toSource {
    root = ./.;
    fileset = fileset.unions [
      ./config.toml
      ./content
      ./static
      ./templates
    ];
  };

  nativeBuildInputs = [ zola ];
  buildPhase = "zola build";

  installPhase = ''
    mkdir -p $out/share

    # output site
    cp -rv public/* $out/

    # copy cv
    cp -v ${depot.misc.cv} $out/share/cv.pdf
  '';
}
