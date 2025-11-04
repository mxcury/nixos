{ config, pkgs, ... }:

{
  home.file.".config/waybar/scripts/power-profile.sh" = {
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
  
      # Get current governor
      governor=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo "unknown")
  
      # Read user preference
      if [ -f "$STATE_FILE" ]; then
        user_pref=$(cat "$STATE_FILE")
      else
        user_pref="normal"
        echo "normal" > "$STATE_FILE"
      fi
  
      # Determine actual mode based on charging status and battery level
      if [ "$status" = "Charging" ] || [ "$status" = "Full" ]; then
        # On charge: use user preference directly
        mode="$user_pref"
      else
        # On battery: apply restrictions
        if [ "$battery" -lt 20 ]; then
          mode="energy-saver"
        elif [ "$battery" -lt 80 ]; then
          # Can't use overdrive
          if [ "$user_pref" = "overdrive" ]; then
            mode="normal"
          else
            mode="$user_pref"
          fi
        else
          # >80%: no restrictions
          mode="$user_pref"
        fi
      fi

      # Map mode to text and governor
      case $mode in
        "energy-saver")
          text="Energy Saving"
          target_gov="powersave"
          ;;
        "normal")
          text="Normal"
          target_gov="powersave"
          ;;
        "overdrive")
          text="Overdrive"
          target_gov="performance"
          ;;
        *)
          text="Normal"
          target_gov="powersave"
          ;;
      esac
  
      # Apply governor if different
      if [ "$governor" != "$target_gov" ] && [ "$target_gov" != "unknown" ]; then
        echo "$target_gov" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor > /dev/null 2>&1
      fi
  
      echo "{\"text\":\"$text\",\"tooltip\":\"Power: $text (Battery: $battery% - $status)\",\"class\":\"$mode\"}"
    '';
    executable = true;
  };
}
