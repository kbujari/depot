{ config, lib, pkgs, ... }:
let
  cfg = config.xnet.desktop;
  inherit (lib) mkDefault mkOption mkIf types;
in
{
  options.xnet.desktop = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable graphical desktop.";
    };
  };

  config = mkIf cfg.enable {
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      pulse.enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
    };

    programs.sway = {
      enable = true;
      wrapperFeatures = {
        gtk = true;
        base = true;
      };
      extraPackages = with pkgs; [
        foot
        fuzzel
        grim
        mako
        pwvucontrol
        playerctl
        pop-icon-theme
        pwvucontrol
        slurp
        sway-contrib.grimshot
        swayidle
        swaylock
        waybar
        wl-clipboard
      ];
      extraSessionCommands = ''
        export MOZ_ENABLE_WAYLAND=1
        export MOZ_USE_XINPUT2=1
        export MOZ_WEBRENDER=1
        export XDG_CURRENT_DESKTOP=sway
        export XDG_SESSION_TYPE=wayland
      '';
    };

    programs.light.enable = mkDefault true;

    qt = {
      enable = true;
      style = "adwaita-dark";
      platformTheme = "gnome";
    };

    fonts.packages = with pkgs; [
      departure-mono
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      (nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; })
    ];

    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-wlr
        xdg-desktop-portal-gtk
      ];
    };

    programs.firefox = {
      enable = true;
      policies = {
        DisableTelemetry = true;
        DisableFirefoxStudies = true;
        EnableTrackingProtection = {
          Value = true;
          Locked = true;
          Cryptomining = true;
          Fingerprinting = true;
        };
        DisablePocket = true;
        DisableFirefoxAccounts = true;
        DisableAccounts = true;
        DisableFirefoxScreenshots = true;
        OverrideFirstRunPage = "";
        OverridePostUpdatePage = "";
        DontCheckDefaultBrowser = true;
        DisplayBookmarksToolbar = "never";
        DisplayMenuBar = "default-off";
        SearchBar = "unified";
        ExtensionSettings = {
          "*".installation_mode = "blocked"; # blocks all addons except the ones specified below
          # uBlock Origin:
          "uBlock0@raymondhill.net" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
            installation_mode = "force_installed";
          };
          # Bitwarden:
          "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
            installation_mode = "force_installed";
          };
          # Dark Reader:
          "addon@darkreader.org" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
            installation_mode = "force_installed";
          };
        };
      };
    };
  };
}
