#!/usr/bin/env bash

# Rofi Brightness Menu

# Get current brightness
CURRENT_BRIGHTNESS=$(brightnessctl g)
MAX_BRIGHTNESS=$(brightnessctl m)
BRIGHTNESS_PERCENT=$((CURRENT_BRIGHTNESS * 100 / MAX_BRIGHTNESS))

# Check if night light is on (using hyprsunset or similar)
# Note: You may need to adjust this based on your night light solution
NIGHT_LIGHT_STATUS="off"
if pgrep -x hyprsunset > /dev/null; then
    NIGHT_LIGHT_STATUS="on"
fi

# Build menu
MENU=""

# Current status
MENU+="[ Brightness: $BRIGHTNESS_PERCENT% ]\n"
MENU+="───────────────────\n"

# Night light toggle
if [ "$NIGHT_LIGHT_STATUS" = "on" ]; then
    MENU+="󰛨  Turn Night Light OFF\n"
else
    MENU+="󰹐  Turn Night Light ON\n"
fi

# Brightness controls
MENU+="\n[ Brightness Levels ]\n"
MENU+="󰃞  Increase +10%\n"
MENU+="󰃞  Increase +5%\n"
MENU+="󰃝  Decrease -5%\n"
MENU+="󰃝  Decrease -10%\n"

MENU+="\n[ Presets ]\n"
MENU+="󰃠  100% (Maximum)\n"
MENU+="󰃟  75% (High)\n"
MENU+="󰃞  50% (Medium)\n"
MENU+="󰃝  25% (Low)\n"
MENU+="󰛨  10% (Minimal)\n"
MENU+="󰽥  5% (Night)\n"

# Show current brightness bar
BAR_LENGTH=20
FILLED=$((BRIGHTNESS_PERCENT * BAR_LENGTH / 100))
EMPTY=$((BAR_LENGTH - FILLED))
BAR=""
for ((i=0; i<FILLED; i++)); do BAR+="█"; done
for ((i=0; i<EMPTY; i++)); do BAR+="░"; done

MENU+="\n[ $BAR ]\n"

# Show menu
CHOICE=$(echo -e "$MENU" | rofi -dmenu -i -p "  Brightness" -theme-str 'window {width: 450px;}' -theme-str 'listview {lines: 16;}')

# Handle selection
case "$CHOICE" in
    *"Night Light (ON)"*)
        # Turn off night light
        pkill hyprsunset
        notify-send "Brightness" "Night Light turned off"
        ;;
    *"Night Light (OFF)"*)
        # Turn on night light (adjust temperature as needed)
        hyprsunset -t 4500 &
        notify-send "Brightness" "Night Light turned on"
        ;;
    *"Increase +10%"*)
        brightnessctl set +10%
        NEW_BRIGHTNESS=$(($(brightnessctl g) * 100 / $(brightnessctl m)))
        notify-send "Brightness" "Brightness: $NEW_BRIGHTNESS%"
        ;;
    *"Increase +5%"*)
        brightnessctl set +5%
        NEW_BRIGHTNESS=$(($(brightnessctl g) * 100 / $(brightnessctl m)))
        notify-send "Brightness" "Brightness: $NEW_BRIGHTNESS%"
        ;;
    *"Decrease -5%"*)
        brightnessctl set 5%-
        NEW_BRIGHTNESS=$(($(brightnessctl g) * 100 / $(brightnessctl m)))
        notify-send "Brightness" "Brightness: $NEW_BRIGHTNESS%"
        ;;
    *"Decrease -10%"*)
        brightnessctl set 10%-
        NEW_BRIGHTNESS=$(($(brightnessctl g) * 100 / $(brightnessctl m)))
        notify-send "Brightness" "Brightness: $NEW_BRIGHTNESS%"
        ;;
    *"100%"*)
        brightnessctl set 100%
        notify-send "Brightness" "Brightness: 100%"
        ;;
    *"75%"*)
        brightnessctl set 75%
        notify-send "Brightness" "Brightness: 75%"
        ;;
    *"50%"*)
        brightnessctl set 50%
        notify-send "Brightness" "Brightness: 50%"
        ;;
    *"25%"*)
        brightnessctl set 25%
        notify-send "Brightness" "Brightness: 25%"
        ;;
    *"10%"*)
        brightnessctl set 10%
        notify-send "Brightness" "Brightness: 10%"
        ;;
    *"5%"*)
        brightnessctl set 5%
        notify-send "Brightness" "Brightness: 5%"
        ;;
esac
