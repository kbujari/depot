{ pkgs, ... }: pkgs.stdenvNoCC.mkDerivation {
  pname = "cv";
  version = "1.0";

  src = ./.;

  nativeBuildInputs = with pkgs; [ typst ];
  buildPhase = "typst compile cv.typ";
  installPhase = ''
    mkdir -p $out/share
    cp cv.pdf $out/share
  '';
}
