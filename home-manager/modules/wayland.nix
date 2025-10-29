{ config, pkgs, ... }:

{
  imports = [
    ./wayland/waybar.nix
    ./wayland/rofi.nix
    ./wayland/mako.nix
    ./wayland/swaylock.nix
    ./wayland/wlogout.nix
  ];

  # Additional Wayland tools
  home.packages = with pkgs; [
    waybar
    mako
    rofi
    swaylock-effects
    swww
    wlogout
    wdisplays
    pavucontrol
    blueman
    brightnessctl
    networkmanagerapplet
  ];
}
