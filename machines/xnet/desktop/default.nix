{ config, lib, pkgs, ... }:
let
  cfg = config.xnet.desktop;
  inherit (lib) mkDefault mkOption mkIf types;
  inherit (builtins) listToAttrs;
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
      };
    };

    programs.sway = {
      enable = true;
      wrapperFeatures = {
        gtk = true;
        base = true;
      };
      xwayland.enable = true;
      extraPackages = with pkgs; [
        foot
        fuzzel
        imv
        mako
        mpv
        playerctl
        pop-icon-theme
        pwvucontrol
        sway-contrib.grimshot
        swayidle
        swaylock
        tigervnc
        udiskie
        waybar
        wl-clipboard
        zathura
      ];
      extraSessionCommands = ''
        export MOZ_ENABLE_WAYLAND=1
        export MOZ_USE_XINPUT2=1
        export MOZ_WEBRENDER=1
        export XDG_CURRENT_DESKTOP=sway
        export XDG_SESSION_TYPE=wayland
      '';
    };

    qt = {
      enable = true;
      style = "adwaita-dark";
      platformTheme = "gnome";
    };

    fonts.packages = with pkgs; [
      departure-mono
      iosevka
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      nerd-fonts.symbols-only
      terminus_font
    ];

    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-wlr
        xdg-desktop-portal-gtk
      ];
    };

    environment.systemPackages = [ pkgs.man-pages pkgs.man-pages-posix ];

    programs = {
      fish = {
        enable = true;
        interactiveShellInit = ''
          # disable greeting
          set fish_greeting
        '';
      };
      light.enable = mkDefault true;
      direnv = {
        enable = true;
        nix-direnv.enable = true;
      };

      # GTK settings
      dconf = {
        enable = true;
        profiles.user.databases = [{
          lockAll = true;
          settings = {
            "org/gnome/desktop/interface" = {
              color-scheme = "prefer-dark";
              gtk-font-name = "System-ui 10";
              icon-theme = "Pop";
              theme-name = "Adwaita-dark";
            };
          };
        }];
      };
    };

    # Helper for managing dotfiles
    environment.shellAliases.dots =
      "git --git-dir=$HOME/.local/cfg/ --work-tree=$HOME";

    # Enable yubikey for SSH and more
    services = {
      yubikey-agent.enable = true;
      pcscd.enable = true;
      udev.packages = with pkgs; [ yubikey-personalization ];
      udisks2.enable = true;
    };

    programs.firefox = {
      enable = true;
      preferences = {
        # Enable hardware transcoding
        "media.ffmpeg.vaapi.enabled" = true;

        # Disable controlling media with keyboard
        "media.hardwaremediakeys.enabled" = false;
        # Enable legacy compact mode
        "browser.compactmode.show" = true;
        "browser.uidensity" = 1;

        # Disable ctrl+q closing browser
        "browser.quitShortcut.disabled" = true;

        # Hardcode theme to dark mode
        "ui.systemUsesDarkTheme" = 1;
      };
      policies = {
        DefaultDownloadDirectory = "/tmp/firefox";
        DisableTelemetry = true;
        DisableFirefoxStudies = true;
        EnableTrackingProtection = {
          Value = true;
          Locked = true;
          Cryptomining = true;
          Fingerprinting = true;
        };
        DisableAccounts = true;
        DisableFirefoxAccounts = true;
        DisableFirefoxScreenshots = true;
        DisablePocket = true;
        DisplayBookmarksToolbar = "never";
        DisplayMenuBar = "default-off";
        DontCheckDefaultBrowser = true;
        Homepage = {
          URL = "about:blank";
          StartPage = "homepage";
        };
        HttpsOnlyMode = "enabled";
        DNSOverHTTPS = false;
        NewTabPage = false;
        OfferToSaveLogins = false;
        PasswordManagerEnabled = false;
        SearchBar = "unified";
        SearchEngines.Default = "DuckDuckGo";
        SearchSuggestEnabled = false;
        ExtensionSettings =
          let
            extension = shortId: uuid: {
              name = uuid;
              value = {
                install_url = "https://addons.mozilla.org/en-US/firefox/downloads/latest/${shortId}/latest.xpi";
                installation_mode = "force_installed";
              };
            };
          in
          listToAttrs [
            (extension "ublock-origin" "uBlock0@raymondhill.net")
            (extension "bitwarden-password-manager" "{446900e4-71c2-419f-a6a7-df9c091e268b}")
            (extension "darkreader" "addon@darkreader.org")
          ];
      };
    };
  };
}
