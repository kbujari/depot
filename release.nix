{ ... }:

let
  depot = import ./. { };
in
{
  inherit (depot.depotPackages.misc) cv;
  inherit (depot.depotPackages.web) site;
}
