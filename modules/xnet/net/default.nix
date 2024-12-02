{ config, lib, ... }:
let
  cfg = config.xnet.net;
  inherit (lib) mkOption mkIf types;
  prefix = "10.26.4";
in
{
  imports = [
    ./sshd.nix
  ];

  options.xnet.net = {
    interface = mkOption {
      type = types.str;
      default = "";
      description = "Network interface connecting to xnet.";
    };

    addr = mkOption {
      type = types.ints.between 0 255;
      description = "Final octet for xnet address.";
      example = 4;
    };
  };

  # TODO:
  #   - Add assertion that each address is only used once across config
  #   - Add each host to each other hosts dns configuration
  config = mkIf (builtins.stringLength cfg.interface > 0) {
    networking.vlans = {
      "${cfg.interface}.4" = {
        inherit (cfg) interface;
        id = 4;
      };
    };

    networking.interfaces = {
      "${cfg.interface}.4".ipv4.addresses = [{
        address = "${prefix}.${toString cfg.addr}";
        prefixLength = 24;
      }];
    };
  };
}
