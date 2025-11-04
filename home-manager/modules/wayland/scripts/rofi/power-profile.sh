#!/usr/bin/env bash

# Rofi Power Profile Menu - Integrates with your existing power profile system

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

# Calculate battery time estimates based on actual power draw
# Try to get current power draw in µW (microwatts)
if [ -f "$BATTERY_PATH/power_now" ]; then
    POWER_NOW=$(cat "$BATTERY_PATH/power_now")
elif [ -f "$BATTERY_PATH/current_now" ] && [ -f "$BATTERY_PATH/voltage_now" ]; then
    CURRENT_NOW=$(cat "$BATTERY_PATH/current_now")
    VOLTAGE_NOW=$(cat "$BATTERY_PATH/voltage_now")
    POWER_NOW=$((CURRENT_NOW * VOLTAGE_NOW / 1000000))
else
    POWER_NOW=0
fi

# Get battery capacity in µWh (microwatt-hours)
if [ -f "$BATTERY_PATH/energy_now" ]; then
    ENERGY_NOW=$(cat "$BATTERY_PATH/energy_now")
elif [ -f "$BATTERY_PATH/charge_now" ] && [ -f "$BATTERY_PATH/voltage_now" ]; then
    CHARGE_NOW=$(cat "$BATTERY_PATH/charge_now")
    VOLTAGE_NOW=$(cat "$BATTERY_PATH/voltage_now")
    ENERGY_NOW=$((CHARGE_NOW * VOLTAGE_NOW / 1000000))
else
    ENERGY_NOW=0
fi

# If we can calculate based on actual power draw, use that
if [ "$POWER_NOW" -gt 0 ] && [ "$ENERGY_NOW" -gt 0 ]; then
    # Calculate hours remaining at current power draw
    # ENERGY_NOW is in µWh, POWER_NOW is in µW
    # Time = Energy / Power (in hours)
    CURRENT_TIME_MINS=$(echo "scale=2; ($ENERGY_NOW / $POWER_NOW) * 60" | bc 2>/dev/null || echo "0")
    
    # Profile multipliers based on typical power usage differences
    # These are educated estimates - energy-saver uses ~60% power, overdrive uses ~140%
    ENERGY_SAVER_MULT="1.67"  # Uses 60% power = 1/0.6 = 1.67x time
    NORMAL_MULT="1.0"         # Baseline
    OVERDRIVE_MULT="0.71"     # Uses 140% power = 1/1.4 = 0.71x time
else
    # Fallback to simple percentage-based estimation (6 min per %)
    CURRENT_TIME_MINS=$((battery * 6))
    ENERGY_SAVER_MULT="1.5"
    NORMAL_MULT="1.0"
    OVERDRIVE_MULT="0.7"
fi

# Build menu
MENU=""

# Current status header
case $mode in
    "energy-saver")
        CURRENT_TEXT="Energy Saving"
        ;;
    "normal")
        CURRENT_TEXT="Normal"
        ;;
    "overdrive")
        CURRENT_TEXT="Overdrive"
        ;;
esac

MENU+="[ Current Mode: $CURRENT_TEXT ]\n"
MENU+="[ Battery: $battery% - $status ]\n"
MENU+="───────────────────\n"

# Determine which profiles are available and build menu
if [ "$status" = "Charging" ] || [ "$status" = "Full" ]; then
    # All modes available when charging
    
    # Energy Saving
    EST_MINS=$(echo "$CURRENT_TIME_MINS * $ENERGY_SAVER_MULT" | bc 2>/dev/null | cut -d'.' -f1)
    EST_HRS=$((EST_MINS / 60))
    EST_MIN=$((EST_MINS % 60))
    if [ "$mode" = "energy-saver" ]; then
        MENU+="󰸞 󰌪  Energy Saving (Active) - Est: ${EST_HRS}h ${EST_MIN}m\n"
    else
        MENU+="  󰌪  Energy Saving - Est: ${EST_HRS}h ${EST_MIN}m\n"
    fi
    
    # Normal
    EST_MINS=$(echo "$CURRENT_TIME_MINS * $NORMAL_MULT" | bc 2>/dev/null | cut -d'.' -f1)
    EST_HRS=$((EST_MINS / 60))
    EST_MIN=$((EST_MINS % 60))
    if [ "$mode" = "normal" ]; then
        MENU+="󰸞 󰾅  Normal (Active) - Est: ${EST_HRS}h ${EST_MIN}m\n"
    else
        MENU+="  󰾅  Normal - Est: ${EST_HRS}h ${EST_MIN}m\n"
    fi
    
    # Overdrive
    EST_MINS=$(echo "$CURRENT_TIME_MINS * $OVERDRIVE_MULT" | bc 2>/dev/null | cut -d'.' -f1)
    EST_HRS=$((EST_MINS / 60))
    EST_MIN=$((EST_MINS % 60))
    if [ "$mode" = "overdrive" ]; then
        MENU+="󰸞 󱐋  Overdrive (Active) - Est: ${EST_HRS}h ${EST_MIN}m\n"
    else
        MENU+="  󱐋  Overdrive - Est: ${EST_HRS}h ${EST_MIN}m\n"
    fi
    
else
    # On battery: show restrictions
    if [ "$battery" -lt 20 ]; then
        # Only energy-saver available
        EST_MINS=$(echo "$CURRENT_TIME_MINS * $ENERGY_SAVER_MULT" | bc 2>/dev/null | cut -d'.' -f1)
        EST_HRS=$((EST_MINS / 60))
        EST_MIN=$((EST_MINS % 60))
        MENU+="󰸞 󰌪  Energy Saving (Forced) - Est: ${EST_HRS}h ${EST_MIN}m\n"
        MENU+="  󰾅  Normal (Unavailable - Battery <20%)\n"
        MENU+="  󱐋  Overdrive (Unavailable - Battery <20%)\n"
        
    elif [ "$battery" -lt 80 ]; then
        # energy-saver and normal available
        
        # Energy Saving
        EST_MINS=$(echo "$CURRENT_TIME_MINS * $ENERGY_SAVER_MULT" | bc 2>/dev/null | cut -d'.' -f1)
        EST_HRS=$((EST_MINS / 60))
        EST_MIN=$((EST_MINS % 60))
        if [ "$mode" = "energy-saver" ]; then
            MENU+="󰸞 󰌪  Energy Saving (Active) - Est: ${EST_HRS}h ${EST_MIN}m\n"
        else
            MENU+="  󰌪  Energy Saving - Est: ${EST_HRS}h ${EST_MIN}m\n"
        fi
        
        # Normal
        EST_MINS=$(echo "$CURRENT_TIME_MINS * $NORMAL_MULT" | bc 2>/dev/null | cut -d'.' -f1)
        EST_HRS=$((EST_MINS / 60))
        EST_MIN=$((EST_MINS % 60))
        if [ "$mode" = "normal" ]; then
            MENU+="󰸞 󰾅  Normal (Active) - Est: ${EST_HRS}h ${EST_MIN}m\n"
        else
            MENU+="  󰾅  Normal - Est: ${EST_HRS}h ${EST_MIN}m\n"
        fi
        
        # Overdrive unavailable
        MENU+="  󱐋  Overdrive (Unavailable - Battery <80%)\n"
        
    else
        # >80%: all modes available
        
        # Energy Saving
        EST_MINS=$(echo "$CURRENT_TIME_MINS * $ENERGY_SAVER_MULT" | bc 2>/dev/null | cut -d'.' -f1)
        EST_HRS=$((EST_MINS / 60))
        EST_MIN=$((EST_MINS % 60))
        if [ "$mode" = "energy-saver" ]; then
            MENU+="󰸞 󰌪  Energy Saving (Active) - Est: ${EST_HRS}h ${EST_MIN}m\n"
        else
            MENU+="  󰌪  Energy Saving - Est: ${EST_HRS}h ${EST_MIN}m\n"
        fi
        
        # Normal
        EST_MINS=$(echo "$CURRENT_TIME_MINS * $NORMAL_MULT" | bc 2>/dev/null | cut -d'.' -f1)
        EST_HRS=$((EST_MINS / 60))
        EST_MIN=$((EST_MINS % 60))
        if [ "$mode" = "normal" ]; then
            MENU+="󰸞 󰾅  Normal (Active) - Est: ${EST_HRS}h ${EST_MIN}m\n"
        else
            MENU+="  󰾅  Normal - Est: ${EST_HRS}h ${EST_MIN}m\n"
        fi
        
        # Overdrive
        EST_MINS=$(echo "$CURRENT_TIME_MINS * $OVERDRIVE_MULT" | bc 2>/dev/null | cut -d'.' -f1)
        EST_HRS=$((EST_MINS / 60))
        EST_MIN=$((EST_MINS % 60))
        if [ "$mode" = "overdrive" ]; then
            MENU+="󰸞 󱐋  Overdrive (Active) - Est: ${EST_HRS}h ${EST_MIN}m\n"
        else
            MENU+="  󱐋  Overdrive - Est: ${EST_HRS}h ${EST_MIN}m\n"
        fi
    fi
fi

# Show menu
CHOICE=$(echo -e "$MENU" | rofi -dmenu -i -p "  Power Profile" -theme-str 'window {width: 550px;}' -theme-str 'listview {lines: 8;}')

# Handle selection - extract the profile type from choice
case "$CHOICE" in
    *"Energy Saving"*"Active"*|*"Energy Saving"*"Forced"*)
        # Already active, do nothing
        ;;
    *"Energy Saving"*)
        if [[ ! "$CHOICE" =~ "Unavailable" ]]; then
            echo "energy-saver" > "$STATE_FILE"
            echo "powersave" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor > /dev/null 2>&1
            notify-send "Power Profile" "Energy Saving"
        fi
        ;;
    *"Normal"*"Active"*)
        # Already active, do nothing
        ;;
    *"Normal"*)
        if [[ ! "$CHOICE" =~ "Unavailable" ]]; then
            echo "normal" > "$STATE_FILE"
            echo "powersave" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor > /dev/null 2>&1
            notify-send "Power Profile" "Normal"
        fi
        ;;
    *"Overdrive"*"Active"*)
        # Already active, do nothing
        ;;
    *"Overdrive"*)
        if [[ ! "$CHOICE" =~ "Unavailable" ]]; then
            echo "overdrive" > "$STATE_FILE"
            echo "performance" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor > /dev/null 2>&1
            notify-send "Power Profile" "Overdrive"
        fi
        ;;
esac
