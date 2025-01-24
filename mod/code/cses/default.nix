{ pkgs ? import <nixpkgs> { }, ... }:

pkgs.mkShell {
  packages = with pkgs; [
    clang-tools
    (writeShellScriptBin "cpprun" ''
      TEMP=".tmp.cpp"
      g++ -std=c++20 -O3 ./problems/"$1.cpp" -o $TEMP
      ./$TEMP
      rm $TEMP
    '')
  ];
}
