{ lib, self, ... }:
let
  inherit (lib) nixosSystem;
  inherit (self.nixosModules) xnet xlib;
in
{
  flake.nixosConfigurations = {
    t480 = nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit xlib; };
      modules = [ ./t480 xnet ];
    };

    iso = nixosSystem {
      system = "x86_64-linux";
      modules = [ ./iso ];
    };

    # t1 = nixosSystem {
    #   system = "x86_64-linux";
    #   modules = [ ./t1 ];
    # };
    #
    # iridium = nixosSystem {
    #   system = "x86_64-linux";
    #   modules = [ ./iridium ];
    # };
  };
}
