{ runCommandNoCC, ... }:

runCommandNoCC "resisto-rs" { } ''
  mkdir -p $out
  cp ${./index.html} $out/index.html
  cp ${./styles.css} $out/styles.css
''
