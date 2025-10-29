{ config, pkgs, inputs, ... }:

{
  imports = [
    ./modules/packages.nix
    ./modules/shell.nix
    ./modules/terminal.nix
    ./modules/neovim.nix
    ./modules/hyprland.nix
    ./modules/firefox.nix
    ./modules/sddm.nix
    ./modules/wayland.nix
];

  home.username = "dev";
  home.homeDirectory = "/home/dev";

  home.stateVersion = "25.05";

  programs.home-manager.enable = true;

  xdg.enable = true;
}
