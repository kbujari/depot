{ config, lib, ... }:
let
  cfg = config.xnet.net;

  inherit (builtins)
    attrNames
    attrValues
    map
    length
    ;

  inherit (lib)
    concatLines
    genAttrs
    mapAttrsToList
    mergeAttrsList
    mkOption
    mkIf
    types
    ;

  # Networks are logical groupings of hosts wired together. This is
  # accomplished using VLANS on the same layer 2 network.
  #
  # Hosts can hard code their spot on a network here. This module aims
  # to generate network information for a host using this set of facts.
  # The module should gracefully fall back to defaults if a given fact
  # is not specified for the host consuming the module.
  #
  # A host will have it's /etc/hosts populated with all other hosts in
  # a network to avoid a dynamic DNS server.
  networks = {

    # Open network for xnet hosts
    plaza = {
      mask = 24;
      vlan = 88;
      hosts = {
        t1 = "10.88.88.1";
        radon = "10.88.88.2";
        iridium = "10.88.88.3";
      };
    };

    # Reserved network for kubernetes related nodes. A distinct network
    # is created here for hosts that provide resources to workers.
    # Generally, nodes on this network are spawned dynamically and are
    # not a part of this NixOS config directly, although they may boot
    # from assets served from a node here.
    kubenet = {
      mask = 24;
      vlan = 42;
      hosts = {
        iridium = "10.88.42.254";
      };
    };
  };
in
{
  imports = [
    ./sshd.nix
  ];

  options.xnet.net = {
    join = mkOption {
      type = types.listOf (types.enum (attrNames networks));
      default = [ ];
      description = "Available networks.";
    };

    interface = mkOption {
      type = types.str;
      default = "";
      description = "Network interface connecting to xnet.";
    };
  };

  config = mkIf ((length cfg.join) > 0) {
    systemd.network =
      let
        name = config.networking.hostName;

        genConfig = net: {
          netdevs."${toString networks.${net}.vlan}-${net}" = {
            netdevConfig.Kind = "vlan";
            netdevConfig.Name = net;
            vlanConfig.Id = networks.${net}.vlan;
          };

          networks."10-${cfg.interface}" = {
            matchConfig.Name = cfg.interface;
            vlan = cfg.join;

            # Accept DHCP on physical interface
            DHCP = "ipv4";

            # Network is up when xnet physical interface gets carrier
            linkConfig.RequiredForOnline = "carrier";
          };

          networks."${toString networks.${net}.vlan}-${net}" = {
            matchConfig.Name = net;

            # Set up address for known host
            address = [ "${networks.${net}.hosts.${name}}/${toString networks.${net}.mask}" ];
          };
        };

        values = attrValues (genAttrs cfg.join genConfig);
      in
      { enable = true; } // mergeAttrsList values;

    networking.extraHosts =
      let
        genHosts = net: concatLines
          (mapAttrsToList (name: value: "${value} ${name} ${name}.${net}.4kb.net")
            networks.${net}.hosts);
      in
      concatLines (map (net: genHosts net) cfg.join);
  };
}
