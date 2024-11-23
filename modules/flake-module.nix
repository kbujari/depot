{ inputs, ... }: {
  flake.nixosModules = {
    xnet.imports = [ ./xnet inputs.disko.nixosModules.disko ];
    xlib.imports = [ ./xlib ];
  };
}
