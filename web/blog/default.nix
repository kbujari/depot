{ pkgs, ... }: pkgs.stdenvNoCC.mkDerivation {
  pname = "4kb.net";
  version = "1.0";
  src = ./.;
  buildInputs = with pkgs; [
    zola
  ];

  buildPhase = "zola build";
  installPhase = ''
    mkdir -p $out
    cp -r public/* $out/
  '';
}
