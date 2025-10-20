{ config, pkgs, ... }:

{
  # SDDM Display Manager
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  # Enable X11 windowing system
  services.xserver.enable = true;
}
