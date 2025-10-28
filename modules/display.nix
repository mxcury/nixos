{ config, pkgs, ... }:

let
  catppuccinTheme = pkgs.catppuccin-sddm.override {
    flavor = "mocha";
    font = "JetBrainsMono Nerd Font Propo";
    fontSize = "12";
    background = "${pkgs.catppuccin-sddm}/share/sddm/themes/catppuccin-mocha/backgrounds/wall.png";
    loginBackground = false;
  };
in
{
  # SDDM Display Manager with Catppuccin theme
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "catppuccin-mocha-mauve";
    package = pkgs.kdePackages.sddm;
  };

  # Install Catppuccin SDDM theme
  environment.systemPackages = [ catppuccinTheme ];
  
  # Configure SDDM to use the theme
  systemd.tmpfiles.rules = [
    "L+ /run/current-system/sw/share/sddm/themes/catppuccin-mocha - - - - ${catppuccinTheme}/share/sddm/themes/catppuccin-mocha"
  ];

  # Enable X11 windowing system
  services.xserver.enable = true;
}
