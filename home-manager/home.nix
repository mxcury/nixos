{ config, pkgs, inputs, ... }:

{
  imports = [
    ./modules/packages.nix
    ./modules/shell.nix
    ./modules/terminal.nix
    ./modules/wayland.nix
    ./modules/hyprland.nix
    ./modules/themes.nix
    ./modules/firefox.nix
];

  home.username = "dev";
  home.homeDirectory = "/home/dev";

  home.stateVersion = "25.05";

  programs.home-manager.enable = true;

  xdg.enable = true;
}
