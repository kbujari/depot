{ pkgs, ... }:

pkgs.stdenvNoCC.mkDerivation {
  pname = "resistors";
  version = "0.0";
  src = ./.;

  buildInputs = [ pkgs.nodePackages.prettier ];

  phases = [ "installPhase" ];
  installPhase = "mkdir -p $out; cp -r $src/*.{css,html} $out/";
}
