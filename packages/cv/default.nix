{ pkgs, ... }:

pkgs.runCommand "cv" { }
  "${pkgs.typst}/bin/typst compile --format pdf ${./cv.typ} $out"
