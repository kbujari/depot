{ pkgs, depot, ... }:
let
  inherit (pkgs)
    symlinkJoin
    ;

  posts = pkgs.stdenvNoCC.mkDerivation {
    pname = "4kb.net";
    version = "1.0";
    src = ./.;

    nativeBuildInputs = with pkgs; [
      zola
    ];

    buildPhase = "zola build";
    installPhase = ''
      mkdir -p $out
      cp -r public/* $out/
    '';
  };

in
symlinkJoin {
  name = "site";
  paths = [
    posts
    depot.misc.cv
  ];
}
