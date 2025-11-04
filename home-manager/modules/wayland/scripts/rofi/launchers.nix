{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    bc  # For calculations
  ];

  home.file = {
    # WiFi launcher
    ".config/rofi/launchers/wifi.sh" = {
      executable = true;
      text = builtins.readFile ./wifi.sh;
    };

    # Bluetooth launcher
    ".config/rofi/launchers/bluetooth.sh" = {
      executable = true;
      text = builtins.readFile ./bluetooth.sh;
    };

    # Microphone launcher
    ".config/rofi/launchers/microphone.sh" = {
      executable = true;
      text = builtins.readFile ./microphone.sh;
    };

    # Power profile launcher
    ".config/rofi/launchers/power-profile.sh" = {
      executable = true;
      text = builtins.readFile ./power-profile.sh;
    };

    # Volume launcher
    ".config/rofi/launchers/volume.sh" = {
      executable = true;
      text = builtins.readFile ./volume.sh;
    };

    # Brightness launcher
    ".config/rofi/launchers/brightness.sh" = {
      executable = true;
      text = builtins.readFile ./brightness.sh;
    };

    # Wallpaper chooser
    ".config/rofi/launchers/wallpaper.sh" = {
      executable = true;
      text = builtins.readFile ./wallpaper.sh;
    };
  };
}
