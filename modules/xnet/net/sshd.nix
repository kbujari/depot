{ config, lib, ... }:
let
  cfg = config.xnet.net.sshd;
  inherit (lib) mkOption mkIf types;
in
{
  options.xnet.net.sshd = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable hardened SSH service.";
    };
  };

  config = mkIf cfg.enable {
    services.openssh = {
      enable = true;
      startWhenNeeded = true;
      openFirewall = true;
      hostKeys = [{
        path = "/persist/certs/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }];
      settings = {
        UsePAM = false;
        X11Forwarding = false;
        PermitRootLogin = "prohibit-password";
        PasswordAuthentication = false;
        Ciphers = [ "chacha20-poly1305@openssh.com" ];
        Macs = [ "hmac-sha2-512-etm@openssh.com" ];
        KexAlgorithms = [ "curve25519-sha256@libssh.org" ];
      };
      sftpServerExecutable = "internal-sftp";
      sftpFlags = [ "-f AUTHPRIV" "-l INFO" ];
      extraConfig =
        let
          pubkeyTypes = lib.strings.concatStringsSep "," [
            "sk-ssh-ed25519-cert-v01@openssh.com"
            "ssh-ed25519-cert-v01@openssh.com"
            "ssh-ed25519"
          ];
        in
        "PubkeyAcceptedKeyTypes ${pubkeyTypes}";
    };
  };
}
