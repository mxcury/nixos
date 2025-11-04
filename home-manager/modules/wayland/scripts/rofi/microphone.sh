#!/usr/bin/env bash

# Rofi Microphone Menu

# Get default source
DEFAULT_SOURCE=$(pactl get-default-source)
SOURCE_INFO=$(pactl list sources | grep -A 20 "Name: $DEFAULT_SOURCE")

# Get current volume
VOLUME=$(echo "$SOURCE_INFO" | grep "Volume:" | head -n1 | awk '{print $5}' | sed 's/%//')

# Get mute status
MUTE_STATUS=$(pactl get-source-mute "$DEFAULT_SOURCE" | awk '{print $2}')

# Get source description
SOURCE_NAME=$(echo "$SOURCE_INFO" | grep "Description:" | cut -d':' -f2- | xargs)

# Build menu
MENU=""

# Current status
if [ "$MUTE_STATUS" = "yes" ]; then
    MENU+="[ $SOURCE_NAME - MUTED ]\n"
    MENU+="───────────────────\n"
    MENU+="󰍬  Unmute Microphone\n"
else
    MENU+="[ $SOURCE_NAME - $VOLUME% ]\n"
    MENU+="───────────────────\n"
    MENU+="󰍭  Mute Microphone\n"
fi

# Volume controls
MENU+="\n[ Volume Controls ]\n"
MENU+="󰝝  Increase +5%\n"
MENU+="󰝞  Decrease -5%\n"
MENU+="󰕾  Set to 100%\n"
MENU+="󰖀  Set to 75%\n"
MENU+="󰕿  Set to 50%\n"
MENU+="󰖁  Set to 25%\n"

# Input sources
MENU+="\n[ Input Sources ]\n"

# List all sources
pactl list sources short | while IFS=$'\t' read -r index name driver desc state; do
    if [ "$name" = "$DEFAULT_SOURCE" ]; then
        MENU+="󰸞  $desc (Active)\n"
    else
        MENU+="   $desc\n"
    fi
done

# Show menu
CHOICE=$(echo -e "$MENU" | rofi -dmenu -i -p "  Microphone" -theme-str 'window {width: 500px;}' -theme-str 'listview {lines: 15;}')

# Handle selection
case "$CHOICE" in
    *"Unmute"*)
        pactl set-source-mute "$DEFAULT_SOURCE" 0
        notify-send "Microphone" "Microphone unmuted"
        ;;
    *"Mute"*)
        pactl set-source-mute "$DEFAULT_SOURCE" 1
        notify-send "Microphone" "Microphone muted"
        ;;
    *"Increase"*)
        pactl set-source-volume "$DEFAULT_SOURCE" +5%
        NEW_VOL=$(pactl list sources | grep -A 20 "Name: $DEFAULT_SOURCE" | grep "Volume:" | head -n1 | awk '{print $5}')
        notify-send "Microphone" "Volume: $NEW_VOL"
        ;;
    *"Decrease"*)
        pactl set-source-volume "$DEFAULT_SOURCE" -5%
        NEW_VOL=$(pactl list sources | grep -A 20 "Name: $DEFAULT_SOURCE" | grep "Volume:" | head -n1 | awk '{print $5}')
        notify-send "Microphone" "Volume: $NEW_VOL"
        ;;
    *"100%"*)
        pactl set-source-volume "$DEFAULT_SOURCE" 100%
        notify-send "Microphone" "Volume: 100%"
        ;;
    *"75%"*)
        pactl set-source-volume "$DEFAULT_SOURCE" 75%
        notify-send "Microphone" "Volume: 75%"
        ;;
    *"50%"*)
        pactl set-source-volume "$DEFAULT_SOURCE" 50%
        notify-send "Microphone" "Volume: 50%"
        ;;
    *"25%"*)
        pactl set-source-volume "$DEFAULT_SOURCE" 25%
        notify-send "Microphone" "Volume: 25%"
        ;;
    *"(Active)"*)
        # Already active, do nothing
        ;;
    *)
        if [ -n "$CHOICE" ] && [ "$CHOICE" != *"["* ] && [ "$CHOICE" != *"───"* ]; then
            # Switch to selected source
            SOURCE_NAME=$(echo "$CHOICE" | sed 's/^[^ ]* *//')
            SOURCE_ID=$(pactl list sources short | grep "$SOURCE_NAME" | awk '{print $2}')
            
            if [ -n "$SOURCE_ID" ]; then
                pactl set-default-source "$SOURCE_ID"
                notify-send "Microphone" "Switched to: $SOURCE_NAME"
            fi
        fi
        ;;
esac
