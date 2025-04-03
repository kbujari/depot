{ pkgs, perSystem, ... }:
let
  inherit (perSystem.self)
    cv
    ;
in
pkgs.stdenvNoCC.mkDerivation {
  name = "megasite";
  src = ./.;

  nativeBuildInputs = with pkgs; [
    zola
  ];

  buildPhase = "zola build";
  installPhase = ''
    mkdir -p $out/share
    cp -r public/* $out/
    cp ${cv} $out/share/cv.pdf
  '';
}
