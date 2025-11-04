#!/usr/bin/env bash

# Rofi Volume Menu

# Get default sink
DEFAULT_SINK=$(pactl get-default-sink)
SINK_INFO=$(pactl list sinks | grep -A 30 "Name: $DEFAULT_SINK")

# Get current volume
VOLUME=$(echo "$SINK_INFO" | grep "Volume:" | head -n1 | awk '{print $5}' | sed 's/%//')

# Get mute status
MUTE_STATUS=$(pactl get-sink-mute "$DEFAULT_SINK" | awk '{print $2}')

# Get sink description
SINK_NAME=$(echo "$SINK_INFO" | grep "Description:" | cut -d':' -f2- | xargs)

# Build menu
MENU=""

# Current status
if [ "$MUTE_STATUS" = "yes" ]; then
    MENU+="[ $SINK_NAME - MUTED ]\n"
    MENU+="───────────────────\n"
    MENU+="󰕾  Unmute Volume\n"
else
    MENU+="[ $SINK_NAME - $VOLUME% ]\n"
    MENU+="───────────────────\n"
    MENU+="󰝟  Mute Volume\n"
fi

# Volume controls
MENU+="\n[ Volume Controls ]\n"
MENU+="󰝝  Increase +5%\n"
MENU+="󰝞  Decrease -5%\n"
MENU+="󰕾  Set to 100%\n"
MENU+="󰖀  Set to 75%\n"
MENU+="󰕿  Set to 50%\n"
MENU+="󰖁  Set to 25%\n"

# Output devices
MENU+="\n[ Output Devices ]\n"

pactl list sinks short | while IFS=$'\t' read -r index name driver desc state; do
    SINK_DESC=$(pactl list sinks | grep -A 20 "Name: $name" | grep "Description:" | cut -d':' -f2- | xargs)
    if [ "$name" = "$DEFAULT_SINK" ]; then
        MENU+="󰸞  $SINK_DESC (Active)\n"
    else
        MENU+="   $SINK_DESC\n"
    fi
done

# Application volume mixer
MENU+="\n[ Application Volume ]\n"

pactl list sink-inputs | grep -E "Sink Input|application.name" | while read -r line; do
    if echo "$line" | grep -q "Sink Input"; then
        INPUT_ID=$(echo "$line" | grep -oP '#\K[0-9]+')
    elif echo "$line" | grep -q "application.name"; then
        APP_NAME=$(echo "$line" | cut -d'=' -f2 | tr -d '"' | xargs)
        
        # Get volume for this input
        INPUT_VOL=$(pactl list sink-inputs | grep -A 20 "Sink Input #$INPUT_ID" | grep "Volume:" | head -n1 | awk '{print $5}')
        
        MENU+="󰕾  $APP_NAME ($INPUT_VOL)\n"
    fi
done

# Show menu
CHOICE=$(echo -e "$MENU" | rofi -dmenu -i -p "  Volume" -theme-str 'window {width: 550px;}' -theme-str 'listview {lines: 18;}')

# Handle selection
case "$CHOICE" in
    *"Unmute Volume"*)
        pactl set-sink-mute "$DEFAULT_SINK" 0
        notify-send "Volume" "Volume unmuted"
        ;;
    *"Mute Volume"*)
        pactl set-sink-mute "$DEFAULT_SINK" 1
        notify-send "Volume" "Volume muted"
        ;;
    *"Increase"*)
        pactl set-sink-volume "$DEFAULT_SINK" +5%
        NEW_VOL=$(pactl list sinks | grep -A 30 "Name: $DEFAULT_SINK" | grep "Volume:" | head -n1 | awk '{print $5}')
        notify-send "Volume" "Volume: $NEW_VOL"
        ;;
    *"Decrease"*)
        pactl set-sink-volume "$DEFAULT_SINK" -5%
        NEW_VOL=$(pactl list sinks | grep -A 30 "Name: $DEFAULT_SINK" | grep "Volume:" | head -n1 | awk '{print $5}')
        notify-send "Volume" "Volume: $NEW_VOL"
        ;;
    *"100%"*)
        pactl set-sink-volume "$DEFAULT_SINK" 100%
        notify-send "Volume" "Volume: 100%"
        ;;
    *"75%"*)
        pactl set-sink-volume "$DEFAULT_SINK" 75%
        notify-send "Volume" "Volume: 75%"
        ;;
    *"50%"*)
        pactl set-sink-volume "$DEFAULT_SINK" 50%
        notify-send "Volume" "Volume: 50%"
        ;;
    *"25%"*)
        pactl set-sink-volume "$DEFAULT_SINK" 25%
        notify-send "Volume" "Volume: 25%"
        ;;
    *"(Active)"*)
        # Already active output device
        ;;
    *)
        if [ -n "$CHOICE" ] && [ "$CHOICE" != *"["* ] && [ "$CHOICE" != *"───"* ]; then
            # Check if it's an application or output device
            if echo "$CHOICE" | grep -q "application"; then
                # Handle application volume control
                APP_NAME=$(echo "$CHOICE" | sed 's/^[^ ]* *//' | sed 's/ (.*//')
                
                # Submenu for app volume
                APP_MENU="󰝝  Increase +5%\n"
                APP_MENU+="󰝞  Decrease -5%\n"
                APP_MENU+="󰝟  Mute Application\n"
                
                APP_CHOICE=$(echo -e "$APP_MENU" | rofi -dmenu -i -p "  $APP_NAME")
                
                # Get input ID
                INPUT_ID=$(pactl list sink-inputs | grep -B 20 "application.name = \"$APP_NAME\"" | grep "Sink Input" | tail -n1 | grep -oP '#\K[0-9]+')
                
                case "$APP_CHOICE" in
                    *"Increase"*)
                        pactl set-sink-input-volume "$INPUT_ID" +5%
                        ;;
                    *"Decrease"*)
                        pactl set-sink-input-volume "$INPUT_ID" -5%
                        ;;
                    *"Mute"*)
                        pactl set-sink-input-mute "$INPUT_ID" toggle
                        ;;
                esac
            else
                # Switch to selected output device
                DEVICE_NAME=$(echo "$CHOICE" | sed 's/^[^ ]* *//')
                SINK_ID=$(pactl list sinks short | grep -F "$DEVICE_NAME" | awk '{print $2}')
                
                if [ -z "$SINK_ID" ]; then
                    # Try to find by description
                    SINK_ID=$(pactl list sinks | grep -B 5 "$DEVICE_NAME" | grep "Name:" | awk '{print $2}')
                fi
                
                if [ -n "$SINK_ID" ]; then
                    pactl set-default-sink "$SINK_ID"
                    notify-send "Volume" "Switched to: $DEVICE_NAME"
                fi
            fi
        fi
        ;;
esac
