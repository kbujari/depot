{ runCommandNoCC, typst, ... }:

runCommandNoCC "cv" { } "${typst}/bin/typst compile --format pdf ${./cv.typ} $out"
