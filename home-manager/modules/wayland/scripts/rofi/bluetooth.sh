#!/usr/bin/env bash

# Rofi Bluetooth Menu using Blueman

# Check if bluetooth is on
BT_STATUS=$(bluetoothctl show | grep "Powered" | awk '{print $2}')

# Build menu
MENU=""

# Power toggle
if [ "$BT_STATUS" = "yes" ]; then
    MENU+="󰂲  Turn Bluetooth OFF\n"
else
    MENU+="󰂯  Turn Bluetooth ON\n"
fi

if [ "$BT_STATUS" = "yes" ]; then
    MENU+="  Open Blueman Manager\n"
    MENU+="  Scan for Devices\n"
    MENU+="───────────────────\n"
    
    # Get paired devices
    PAIRED=$(bluetoothctl devices Paired 2>/dev/null | cut -d' ' -f2-)
    
    if [ -n "$PAIRED" ]; then
        MENU+="[ Paired Devices ]\n"
        
        while IFS= read -r line; do
            MAC=$(echo "$line" | awk '{print $1}')
            NAME=$(echo "$line" | cut -d' ' -f2-)
            
            # Check if connected
            INFO=$(bluetoothctl info "$MAC" 2>/dev/null)
            CONNECTED=$(echo "$INFO" | grep "Connected" | awk '{print $2}')
            
            if [ "$CONNECTED" = "yes" ]; then
                MENU+="󰂱  $NAME (Connected)\n"
            else
                MENU+="󰂯  $NAME\n"
            fi
        done <<< "$PAIRED"
    fi
    
    # Get available devices (not paired)
    MENU+="\n[ Available Devices ]\n"
    
    # Start scanning briefly
    timeout 3 bluetoothctl scan on &>/dev/null &
    sleep 3
    
    AVAILABLE=$(bluetoothctl devices 2>/dev/null | cut -d' ' -f2-)
    
    while IFS= read -r line; do
        MAC=$(echo "$line" | awk '{print $1}')
        NAME=$(echo "$line" | cut -d' ' -f2-)
        
        # Check if already paired
        if ! echo "$PAIRED" | grep -q "$MAC"; then
            MENU+="󰂲  $NAME (New)\n"
        fi
    done <<< "$AVAILABLE"
fi

# Show menu
CHOICE=$(echo -e "$MENU" | rofi -dmenu -i -p "  Bluetooth" -theme-str 'window {width: 500px;}' -theme-str 'listview {lines: 12;}')

# Handle selection
case "$CHOICE" in
    *"Turn Bluetooth OFF"*)
        bluetoothctl power off
        notify-send "Bluetooth" "Bluetooth turned off"
        ;;
    *"Turn Bluetooth ON"*)
        bluetoothctl power on
        notify-send "Bluetooth" "Bluetooth turned on"
        sleep 1
        "$0"
        ;;
    *"Open Blueman Manager"*)
        blueman-manager &
        ;;
    *"Scan for Devices"*)
        notify-send "Bluetooth" "Scanning for devices..."
        bluetoothctl scan on &
        SCAN_PID=$!
        sleep 5
        kill $SCAN_PID 2>/dev/null
        "$0"
        ;;
    *"(Connected)"*)
        # Disconnect device
        NAME=$(echo "$CHOICE" | sed 's/^[^ ]* *//' | sed 's/ (Connected)//')
        MAC=$(bluetoothctl devices Paired 2>/dev/null | grep "$NAME" | awk '{print $2}')
        
        if [ -n "$MAC" ]; then
            bluetoothctl disconnect "$MAC"
            notify-send "Bluetooth" "Disconnected from $NAME"
        fi
        ;;
    *"(New)"*)
        # Pair and connect new device via CLI
        NAME=$(echo "$CHOICE" | sed 's/^[^ ]* *//' | sed 's/ (New)//')
        MAC=$(bluetoothctl devices 2>/dev/null | grep "$NAME" | awk '{print $2}')
        
        if [ -n "$MAC" ]; then
            notify-send "Bluetooth" "Pairing with $NAME..."
            
            # Use expect-style interaction for pairing
            (
                echo "pair $MAC"
                sleep 2
                echo "trust $MAC"
                sleep 1
                echo "connect $MAC"
                sleep 2
            ) | bluetoothctl
            
            # Check if successful
            sleep 1
            CONNECTED=$(bluetoothctl info "$MAC" 2>/dev/null | grep "Connected: yes")
            if [ -n "$CONNECTED" ]; then
                notify-send "Bluetooth" "Successfully connected to $NAME"
            else
                notify-send "Bluetooth" "Failed to connect to $NAME"
            fi
        fi
        ;;
    *)
        if [ -n "$CHOICE" ] && [ "$CHOICE" != *"["* ] && [ "$CHOICE" != *"───"* ]; then
            # Connect to paired device
            NAME=$(echo "$CHOICE" | sed 's/^[^ ]* *//')
            MAC=$(bluetoothctl devices Paired 2>/dev/null | grep "$NAME" | awk '{print $2}')
            
            if [ -n "$MAC" ]; then
                bluetoothctl connect "$MAC" && \
                    notify-send "Bluetooth" "Connected to $NAME" || \
                    notify-send "Bluetooth" "Failed to connect to $NAME"
            fi
        fi
        ;;
esac
