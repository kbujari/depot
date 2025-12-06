# Generate mostly random string with alphanumerics
# ARGS
#   $1: num of chars to output, default 14

{ writeShellScriptBin, ... }:

writeShellScriptBin "randpass"
  ''tr -dc '[:alnum:]' </dev/urandom | head -c "''${1:-14}"''
