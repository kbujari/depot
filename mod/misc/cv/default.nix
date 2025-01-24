{ pkgs, ... }:

pkgs.runCommand "cv" { } ''
  mkdir -p $out/share
  ${pkgs.typst}/bin/typst compile ${./cv.typ} $out/share/cv.pdf
''
