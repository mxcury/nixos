{ config, pkgs, inputs, ... }:

{
  imports = [
    ../../modules/hyprland.nix
    ../../modules/display.nix
    ../../modules/fingerprint.nix
  ];

  # Garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.configurationLimit = 5;
  boot.kernelParams = [ "mem_sleep_default=s2idle" ];

  # System name
  system.name = "nixpad";

  # Hostname
  networking.hostName = "nixpad";
  networking.networkmanager.enable = true;

  # Timezone and locale
  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };

  # UK Keyboard layout
  console.keyMap = "uk";
  services.xserver.xkb = {
    layout = "gb";
    variant = "";
  };

  # Sound
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Docker
  virtualisation.docker.enable = true;

  # System packages
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    usbutils
    libnotify
  ];

  # User settings
  users.defaultUserShell = pkgs.zsh;
  programs.zsh.enable = true;

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    noto-fonts
    noto-fonts-emoji
    font-awesome
  ];

  # Polkit
  security.polkit.enable = true;

  # User account
  users.users.dev = {
    isNormalUser = true;
    description = "Developer";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
  };

  # Thinkpad 
  services.tlp.enable = true;
  services.fstrim.enable = true;

  # Sudo permissions for power profiling
  security.sudo.extraRules = [{
  users = [ "dev" ];  # Replace with your actual username
  commands = [{
    command = "/run/current-system/sw/bin/tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor";
    options = [ "NOPASSWD" ];
  }];
}];
}
