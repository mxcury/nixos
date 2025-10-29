{ config, pkgs, ... }:

{
  home.file.".config/waybar/scripts/power-profile.sh" = {
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
  
      # Get current governor
      governor=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo "unknown")
  
      # Read user preference
      if [ -f "$STATE_FILE" ]; then
        user_pref=$(cat "$STATE_FILE")
      else
        user_pref="balanced"
        echo "balanced" > "$STATE_FILE"
      fi
  
      # Determine actual mode based on battery
      if [ "$battery" -lt 20 ]; then
        mode="power-saver"
        text="Energy Saving"
        target_gov="powersave"
      elif [ "$battery" -lt 80 ]; then
        mode="balanced"
        text="Normal"
        target_gov="powersave"
      else
        mode="$user_pref"
        case $mode in
          "power-saver")
            text="Energy Saving"
            target_gov="powersave"
            ;;
          "balanced")
            text="Normal"
            target_gov="powersave"
            ;;
          "performance")
            text="Overdrive"
            target_gov="performance"
            ;;
        esac
      fi
  
      # Apply governor if different
      if [ "$governor" != "$target_gov" ] && [ "$target_gov" != "unknown" ]; then
        echo "$target_gov" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor > /dev/null 2>&1
      fi
  
      echo "{\"text\":\"$text\",\"tooltip\":\"Power: $text (Battery: $battery%)\",\"class\":\"$mode\"}"
    '';
    executable = true;
  };
}
