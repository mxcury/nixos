{ config, pkgs, ... }:

{
  home.file.".config/waybar/scripts/power-profile-toggle.sh" = {
    text = ''
      #!/usr/bin/env bash
  
      STATE_FILE="$HOME/.cache/power-profile-state"
      BATTERY_PATH="/sys/class/power_supply/BAT0"
  
      # Get current battery percentage and charging status
      if [ -f "$BATTERY_PATH/capacity" ]; then
        battery=$(cat "$BATTERY_PATH/capacity")
      else
        battery=100
      fi

      if [ -f "$BATTERY_PATH/status" ]; then
        status=$(cat "$BATTERY_PATH/status")
      else
        status="Unknown"
      fi
  
      # Read current preference
      if [ -f "$STATE_FILE" ]; then
        current=$(cat "$STATE_FILE")
      else
        current="normal"
      fi
  
      # Determine available modes based on charging status and battery level
      if [ "$status" = "Charging" ] || [ "$status" = "Full" ]; then
        # On charge: all modes available
        case $current in
          "energy-saver")
            next="normal"
            ;;
          "normal")
            next="overdrive"
            ;;
          "overdrive")
            next="energy-saver"
            ;;
          *)
            next="normal"
            ;;
        esac
      else
        # On battery: apply restrictions
        if [ "$battery" -lt 20 ]; then
          # Can only use energy-saver
          next="energy-saver"
          if [ "$current" != "energy-saver" ]; then
            notify-send "Power Profile" "Battery <20%: Energy Saving mode only"
          fi
        elif [ "$battery" -lt 80 ]; then
          # Can only cycle between energy-saver and normal
          case $current in
            "energy-saver")
              next="normal"
              ;;
            "normal")
              next="energy-saver"
              ;;
            "overdrive")
              next="energy-saver"
              notify-send "Power Profile" "Battery <80%: Overdrive unavailable"
              ;;
            *)
              next="normal"
              ;;
          esac
        else
          # >80%: all modes available
          case $current in
            "energy-saver")
              next="normal"
              ;;
            "normal")
              next="overdrive"
              ;;
            "overdrive")
              next="energy-saver"
              ;;
            *)
              next="normal"
              ;;
          esac
        fi
      fi
  
      # Save preference
      echo "$next" > "$STATE_FILE"
  
      # Apply immediately
      case $next in
        "energy-saver")
          echo "powersave" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor > /dev/null 2>&1
          notify-send "Power Profile" "Energy Saving"
          ;;
        "normal")
          echo "powersave" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor > /dev/null 2>&1
          notify-send "Power Profile" "Normal"
          ;;
        "overdrive")
          echo "performance" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor > /dev/null 2>&1
          notify-send "Power Profile" "Overdrive"
          ;;
      esac
    '';
    executable = true;
  };
}
