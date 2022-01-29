{config, pkgs, lib, ...}:
let
  uboot = pkgs.ubootROCPCRK3399;
in
{
  imports = [

    <nixpkgs/nixos/modules/profiles/minimal.nix>
    <nixpkgs/nixos/modules/profiles/installation-device.nix>
    <nixpkgs/nixos/modules/installer/sd-card/sd-image-aarch64.nix>
  ];


  nixpkgs.crossSystem = {
    system = "aarch64-linux";
  };

  sdImage = {
    postBuildCommands = ''
      (PS4=" $ "; set -x
      dd if=${uboot}/idbloader.img of=$img bs=512 seek=64 conv=notrunc
      dd if=${uboot}/u-boot.itb of=$img bs=512 seek=16384 conv=notrunc
      )
    '';
    compressImage = lib.mkForce false;
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.initrd.kernelModules = [
    # Rockchip modules
    "rockchip_rga"
    "rockchip_saradc"
    "rockchip_thermal"
    "rockchipdrm"

    # GPU/Display modules
    "analogix_dp"
    "cec"
    "drm"
    "drm_kms_helper"
    "dw_hdmi"
    "dw_mipi_dsi"
    "gpu_sched"
    "panel_simple"
    "panfrost"
    "pwm_bl"
  ];

  hardware.enableRedistributableFirmware = true;

  # (Failing build in a dep to be investigated)
  security.polkit.enable = false;
  services.udisks2.enable = false;

  # cifs-utils fails to cross-compile
  # Let's simplify this by removing all unneeded filesystems from the image.
  boot.supportedFilesystems = lib.mkForce [ "vfat" ];

  # texinfoInteractive has trouble cross-compiling
  #documentation.info.enable = lib.mkForce false;

  # `xterm` is being included even though this is GUI-less.
  # → https://github.com/NixOS/nixpkgs/pull/62852
  #services.xserver.desktopManager.xterm.enable = lib.mkForce false;
}
