{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    # Icons and themes
    adwaita-icon-theme

    # Webcam
    obs-studio

    # Bluetooth
    bluetuith

    # Editors
    neovim
    obsidian

    # Communication
    discord

    # Development
    docker
    lazygit
    onefetch
    git

    # File management
    superfile
    yazi
    stow

    # System monitoring
    btop
    htop

    # System info
    neofetch
    pfetch

    # CLI utils
    tty-clock
    wego
    calcurse
    cava
    cmatrix
    pipes-rs
    cbonsai
    asciiquarium
    fzf
    ripgrep
    eza
    bat
    fd
    spotify-player

    # Wayland utils
    grim
    slurp
    wl-clipboard

    # Network
    networkmanagerapplet
  ];
}
