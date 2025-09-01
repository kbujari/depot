{ lib, pkgs, ... }:
let
  inherit (lib) mkDefault;
  inherit (builtins) listToAttrs;
in
{
  environment.systemPackages = with pkgs; [
    audacious
    foot
    fuzzel
    imv
    man-pages
    man-pages-posix
    mpv
    playerctl
    pop-icon-theme
    pwvucontrol
    swayidle
    swaylock
    tigervnc
    wl-clipboard
    xorg.xeyes
    xwayland-satellite
    zathura

    ((emacsPackagesFor emacs-pgtk).emacsWithPackages (epkgs: [
      epkgs.mu4e
      epkgs.treesit-grammars.with-all-grammars
    ]))
  ];

  documentation = {
    doc.enable = true;
    info.enable = true;
  };

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
  };

  # Build nix derivations on disk rather than in /tmp which is mounted
  # in RAM, otherwise large closures fail to build due to lack of
  # space. Since desktops are used as dev machines, this option lives
  # here rather than on a more general module.
  systemd.services.nix-daemon.environment.TMPDIR = "/nix/tmp";

  # Make sure the directory for evaluating large closures exists for
  # the nix daemon.
  systemd.tmpfiles.rules = [ "d /nix/tmp 755 root root - -" ];

  systemd.user.services =
    let
      afterGraphical = ExecStart: {
        enable = true;
        after = [ "graphical-session.target" ];
        partOf = [ "graphical-session.target" ];
        wantedBy = [ "graphical-session.target" ];
        serviceConfig = {
          inherit ExecStart;
          Type = "simple";
        };
      };
    in
    {
      mako = afterGraphical "${pkgs.mako}/bin/mako";
      udiskie = afterGraphical "${pkgs.udiskie}/bin/udiskie";
      xwayland = afterGraphical "${pkgs.xwayland-satellite}/bin/xwayland-satellite";
      swayidle =
        let
          swaylock = lib.concatStringsSep " " [
            "${pkgs.swaylock}/bin/swaylock"
            "--color 2b3328"
            "--indicator-caps-lock"
            "--ignore-empty-password"
            "--daemonize"
          ];
        in
        afterGraphical (
          pkgs.writeShellScript "start-swayidle" ''
            ${pkgs.swayidle}/bin/swayidle -w \
            timeout 601 '${pkgs.niri}/bin/niri msg action power-off-monitors' \
            timeout 600 '${swaylock}' \
            before-sleep '${swaylock}'
          ''
        );

      waybar = {
        partOf = [ "graphical-session.target" ];
        wantedBy = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];

        path = with pkgs; [
          pwvucontrol
        ];

        serviceConfig = {
          Type = "exec";
          ExecStart = "${pkgs.waybar}/bin/waybar";
          ExecReload = "kill -SIGUSR2 $MAINPID";
          Restart = "on-failure";
        };
      };
    };

  qt = {
    enable = true;
    style = "adwaita-dark";
    platformTheme = "gnome";
  };

  fonts = {
    # Expose system fonts in case something non-standard needs them
    fontDir.enable = true;
    packages = with pkgs; [
      departure-mono
      iosevka
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      nerd-fonts.symbols-only
    ];

    fontconfig.defaultFonts = {
      serif = [ "Liberation Serif" ];
      sansSerif = [ "Liberation Sans" ];
      monospace = [ "Iosevka" ];
    };
  };

  environment.etc."xdg/user-dirs.defaults".text = ''
    DOWNLOAD=/tmp/downloads
  '';

  environment.sessionVariables = {
    MOZ_ENABLE_WAYLAND = 1;
    MOZ_USE_XINPUT2 = 1;
    MOZ_WEBRENDER = 1;
    # XDG_CURRENT_DESKTOP = "niri";
    # XDG_SESSION_TYPE = "wayland";
  };

  programs = {
    niri.enable = true;
    light.enable = mkDefault true;
    direnv.enable = true;
    fish = {
      enable = true;
      interactiveShellInit = ''
        # disable greeting
        set fish_greeting
      '';
    };

    # GTK settings
    dconf = {
      enable = true;
      profiles.user.databases = [
        {
          lockAll = true;
          settings = {
            "org/gnome/desktop/interface" = {
              color-scheme = "prefer-dark";
              gtk-font-name = "System-ui 10";
              icon-theme = "Pop";
              theme-name = "Adwaita-dark";
            };
          };
        }
      ];
    };
  };

  # Helper for managing dotfiles
  environment.shellAliases.dots = "git --git-dir=$HOME/.local/cfg/ --work-tree=$HOME";

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
}
