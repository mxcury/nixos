{ config, pkgs, ... }:

{
  home.file.".config/waybar/scripts/power-profile-toggle.sh" = {
    text = ''
      #!/usr/bin/env bash
  
      STATE_FILE="$HOME/.cache/power-profile-state"
      BATTERY_PATH="/sys/class/power_supply/BAT0"
  
      # Get current battery percentage
      if [ -f "$BATTERY_PATH/capacity" ]; then
        battery=$(cat "$BATTERY_PATH/capacity")
      else
        battery=100
      fi
  
      # Read current preference
      if [ -f "$STATE_FILE" ]; then
        current=$(cat "$STATE_FILE")
      else
        current="balanced"
      fi
  
      # Cycle through modes
      case $current in
        "power-saver")
          next="balanced"
          ;;
        "balanced")
          next="performance"
          ;;
        "performance")
          next="power-saver"
          ;;
        *)
          next="balanced"
          ;;
      esac
  
      # Save preference
      echo "$next" > "$STATE_FILE"
  
      # Apply immediately if battery allows
      if [ "$battery" -lt 20 ]; then
        notify-send "Power Profile" "Preference: $next → Using Energy Saving (battery <20%)"
      elif [ "$battery" -lt 80 ]; then
        notify-send "Power Profile" "Preference: $next → Using Normal (battery <80%)"
      else
        case $next in
          "power-saver")
            echo "powersave" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor > /dev/null
            notify-send "Power Profile" "Energy Saving"
            ;;
          "balanced")
            echo "powersave" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor > /dev/null
            notify-send "Power Profile" "Normal"
            ;;
          "performance")
            echo "performance" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor > /dev/null
            notify-send "Power Profile" "Overdrive"
            ;;
        esac
      fi
    '';
    executable = true;
  };
}
