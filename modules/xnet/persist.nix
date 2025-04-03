{ config, lib, ... }:
let
  inherit (lib)
    concatLists
    isString
    mkOption
    types
    ;

in
{
  options.xnet.persist = mkOption {
    type = types.listOf (types.either
      types.str
      (types.submodule {
        options = {
          path = mkOption {
            type = types.str;
            description = "Path to persist";
          };
          user = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "User ID to set on the persisted directory";
          };
          group = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Group ID to set on the persisted directory";
          };

          mode = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Permissions to set";
          };
        };
      }));
    default = [ ];
    description = "Automatically persisted state.";
  };

  config.systemd.tmpfiles.rules =
    let
      mkEntry = entry:
        let
          path = if isString entry then entry else entry.path;
          user = if isString entry then "-" else entry.user;
          group = if isString entry then "-" else entry.group;
          mode = if isString entry then "-" else entry.mode;

          dent = "d /persist${path} ${mode} ${user} ${group} - -";
          link = "L+ ${path} - - - - /persist${path}";
          perm = "Z ${mode} ${user} ${group} - -";
        in
        [ dent link perm ];

      entries = map mkEntry config.xnet.persist;
    in
    concatLists entries;
}
