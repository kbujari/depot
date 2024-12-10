{ lib, self, ... }:
let
  inherit (lib) nixosSystem;
  inherit (self.nixosModules) xnet xlib;
  inherit (self) inputs;
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

    t1 = nixosSystem {
      system = "x86_64-linux";
      modules = [ ./t1 xnet ];
    };

    iridium = nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [ ./iridium xnet ];
    };
  };

  perSystem = { pkgs, inputs', ... }: {
    packages.xinstall =
      let
        disko = inputs'.disko.packages.disko-install;

        configs = builtins.concatStringsSep " "
          (builtins.filter (x: x != "iso")
            (builtins.attrNames self.nixosConfigurations));
      in
      pkgs.writeShellScriptBin "xinstall" ''
        set -euo pipefail

        FLAKE="github:kbujari/depot"
        TARGET=$(${pkgs.gum}/bin/gum choose ${configs})

        # ${disko}/bin/disko-install --help
      '';
  };
}
