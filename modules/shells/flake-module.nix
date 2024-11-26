{ ... }: {
  perSystem = { pkgs, ... }: {
    devShells.typst = pkgs.mkShell {
      buildInputs = with pkgs; [
        tinymist
        typstyle
        typst
      ];
    };

    devShells.rust = pkgs.mkShell {
      buildInputs = with pkgs; [
        rustc
        cargo
        clippy
        rustfmt
        rust-analyzer
        pkg-config # native deps
        openssl # native ssl
      ];
    };
  };
}
