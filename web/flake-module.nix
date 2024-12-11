{ ... }: {
  perSystem = { pkgs, ... }: {
    packages.blog = pkgs.callPackage ./blog { };
  };
}
