{ inputs
, systems
, nixpkgs ? inputs.nixpkgs
, ...
}:

let
  inherit (builtins)
    match
    head
    readDir
    ;

  inherit (nixpkgs.lib)
    callPackageWith
    filterAttrs
    genAttrs
    makeScope
    mapAttrs
    mapAttrs'
    ;

  importDir =
    path: fn:
    let
      entries = readDir path;

      # Get paths to directories
      onlyDirs = filterAttrs (_name: type: type == "directory") entries;
      dirPaths = mapAttrs
        (name: type: {
          path = path + "/${name}";
          inherit type;
        })
        onlyDirs;

      # Get paths to nix files, where the name is the basename of the file without the .nix extension
      nixPaths = removeAttrs
        (mapAttrs'
          (
            name: type:
              let
                nixName = match "(.*)\\.nix" name;
              in
              {
                name = if type == "directory" || nixName == null then "__junk" else (head nixName);
                value = {
                  path = path + "/${name}";
                  type = type;
                };
              }
          )
          entries) [ "__junk" ];

      combined = dirPaths // nixPaths;
    in
    fn combined;

  # Memoize the args per system
  systemArgs = genAttrs systems (
    system:
    let
      # Resolve the packages for each input.
      perSystem = mapAttrs
        (_: flake: flake.legacyPackages.${system} or { } // flake.packages.${system} or { })
        inputs;

      # Handle nixpkgs specially.
      pkgs =
        if (nixpkgs.config or { }) == { } && (nixpkgs.overlays or [ ]) == [ ] then
          perSystem.nixpkgs
        else
          import inputs.nixpkgs {
            inherit system;
            config = nixpkgs.config or { };
            overlays = nixpkgs.overlays or [ ];
          };

      flake = inputs.self;
    in
    makeScope callPackageWith (_: { inherit inputs perSystem flake pkgs system; })
  );
in
{ inherit importDir systemArgs; }
