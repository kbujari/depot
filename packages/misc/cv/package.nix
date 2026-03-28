{ runCommand, typst, ... }:

runCommand "cv" { } "${typst}/bin/typst compile --format pdf ${./cv.typ} $out"
