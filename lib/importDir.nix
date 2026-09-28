{ lib, ... }:
let
  inherit (builtins)
    head
    mapAttrs
    match
    readDir
    ;

  inherit (lib)
    mapAttrs'
    filterAttrs
    ;
in

path: fn:
let
  entries = readDir path;

  # Get paths to directories
  onlyDirs = filterAttrs (_name: type: type == "directory") entries;
  dirPaths = mapAttrs (name: type: {
    path = path + "/${name}";
    inherit type;
  }) onlyDirs;

  # Get paths to nix files, where the name is the basename of the file without the .nix extension
  nixPaths = removeAttrs (mapAttrs' (
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
  ) entries) [ "__junk" ];

  combined = dirPaths // nixPaths;
in
fn combined
