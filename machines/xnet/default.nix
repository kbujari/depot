{ lib, pkgs, ... }:
let
  inherit (lib) mkDefault;
in
{
  imports = [
    ./disk.nix
    ./users.nix
    ./nginx.nix
    ./net
    ./desktop
    ./gitserver
    # ./monitoring
  ];

  i18n.defaultLocale = mkDefault "en_US.UTF-8";
  time.timeZone = mkDefault "America/Toronto";

  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
      warn-dirty = false;

      # timeout fast from binary cache
      connect-timeout = 5;
    };
    gc = {
      automatic = true;
      options = mkDefault "--delete-older-than 30d";
    };
  };

  documentation = {
    doc.enable = mkDefault false;
    info.enable = mkDefault false;
  };
}
