{
  config,
  lib,
  ...
}:

let
  cfg = config.depot.net.sshd;
  inherit (lib)
    mkOption
    mkDefault
    mkIf
    types
    ;
in
{
  options.depot.net.sshd = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable hardened SSH service.";
    };
    publish = mkOption {
      type = types.bool;
      default = false;
      description = "Publish SSH service over mDNS.";
    };
  };

  config = mkIf cfg.enable {
    services.openssh = {
      enable = true;
      startWhenNeeded = true;
      openFirewall = true;
      hostKeys = lib.singleton {
        path = "/persist/certs/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      };
      settings = {
        UsePAM = false;
        X11Forwarding = false;
        PermitRootLogin = "prohibit-password";
        PasswordAuthentication = mkDefault false;
        # Ciphers = [ "chacha20-poly1305@openssh.com" ];
        # Macs = [ "hmac-sha2-512-etm@openssh.com" ];
        # KexAlgorithms = [ "curve25519-sha256@libssh.org" ];
      };
      sftpServerExecutable = "internal-sftp";
      sftpFlags = [
        "-f AUTHPRIV"
        "-l INFO"
      ];
      # extraConfig =
      #   let
      #     pubkeyTypes = lib.strings.concatStringsSep "," [
      #       "sk-ssh-ed25519-cert-v01@openssh.com"
      #       "ssh-ed25519-cert-v01@openssh.com"
      #       "ssh-ed25519"
      #     ];
      #   in
      #   "PubkeyAcceptedKeyTypes ${pubkeyTypes}";
    };

    environment.etc."systemd/dnssd/ssh.dnssd".text = mkIf cfg.publish ''
      [Service]
      Name=%H
      Type=_ssh._tcp
      Port=22
      TxtText=hello world
    '';
  };
}
