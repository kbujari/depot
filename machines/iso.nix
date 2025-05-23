{ modulesPath, pkgs, ... }: {
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
    (modulesPath + "/installer/cd-dvd/channel.nix")
  ];

  nixpkgs.hostPlatform.system = "x86_64-linux";
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
  };

  environment.systemPackages = with pkgs; [
    bash
    git
    gum
    jq
    (writeShellScriptBin "xinstall" ''
      set -euo pipefail

      FLAKE="github:kbujari/depot/xnet"

      TARGET=$(
        nix flake show "$FLAKE" --json 2>/dev/null \
          | jq -r '.["nixosConfigurations"] | keys[] | select(. != "iso")' \
          | gum choose
      )

      gum confirm --default=false "This will erase the selected disk, confirm:"

      echo selected "$FLAKE"#"$TARGET"
    '')
  ];
}
