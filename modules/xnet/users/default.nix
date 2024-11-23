{ ... }: {
  imports = [ ./radicale.nix ];

  security.sudo = {
    execWheelOnly = true;
    extraConfig = "Defaults lecture = never";
  };
}
