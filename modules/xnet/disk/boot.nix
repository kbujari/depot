{ lib, ... }:
let
  inherit (lib) mkDefault;
in
{
  boot = {
    loader.systemd-boot.enable = true;
    initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" "sdhci_pci" ];
    kernelModules = [ "kvm-intel" "kvm-amd" ];
    swraid.mdadmConf = "MAILADDR = nobody@example.com";
    tmp.cleanOnBoot = mkDefault true;
  };
}
