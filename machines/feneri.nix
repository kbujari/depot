{ flake, modulesPath, ... }:

{
  imports = [
    # flake.outputs.nixosModules.disk
    # flake.outputs.nixosModules.network
    (modulesPath + "/profiles/qemu-guest.nix")
    (modulesPath + "/virtualisation/qemu-guest-agent.nix")
  ];

  services.qemuGuest.enable = true;
  nixpkgs.hostPlatform.system = "x86_64-linux";

  depot.disk = {
    enable = true;
    # device = "/dev/vda";
  };

  xnet = {
    nginx.enable = true;
    gitServer = {
      enable = true;
      path = "/var/lib/gitsrv";
      gitweb.enable = true;
    };
  };

  depot.net = {
    sshd.enable = true;
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "certs@4kb.net";
    certs."4kb.net" = {
      dnsProvider = "porkbun";
      environmentFile = "/var/secrets/porkbun";
      extraDomainNames = [ "*.4kb.net" "*.web.4kb.net" ];
      group = "nginx";
      reloadServices = [ "nginx.service" ];
    };
  };

  networking.hostName = "feneri";
}
