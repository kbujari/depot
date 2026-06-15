{ pkgs, ... }: {
  boot.kernelParams = [ "i915.enable_guc=2" ];

  hardware = {
    cpu.intel.updateMicrocode = true;

    graphics = {
      enable = true;
      enable32Bit = true;

      # Here we prefer the legacy Intel GPU packages since I only own
      # skylake-based systems
      extraPackages = with pkgs; [
        # accelerated video playback
        intel-vaapi-driver
        intel-media-driver
        libva-vdpau-driver

        # OpenCL and other compute fun
        intel-compute-runtime-legacy1
      ];

      extraPackages32 = with pkgs.driversi686Linux; [
        intel-media-driver
        libva-vdpau-driver
      ];
    };
  };
}
