#!/usr/bin/env bash

# Rofi WiFi Menu

# Get current connection
CURRENT_WIFI=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d':' -f2)
CURRENT_ETH=$(nmcli -t -f device,state dev status | grep 'ethernet:connected' | cut -d':' -f1)

# Check airplane mode
AIRPLANE_MODE=$(nmcli radio wifi)

# Build menu
MENU=""

# Airplane mode toggle
if [ "$AIRPLANE_MODE" = "enabled" ]; then
    MENU+="✈  Airplane Mode (OFF)\n"
else
    MENU+="✈  Airplane Mode (ON)\n"
fi

# Ethernet status
if [ -n "$CURRENT_ETH" ]; then
    MENU+="󰈀  Ethernet - Connected\n"
fi

# Disconnect option if connected
if [ -n "$CURRENT_WIFI" ]; then
    MENU+="󰖪  Disconnect from \"$CURRENT_WIFI\"\n"
fi

MENU+="  Refresh Networks\n"
MENU+="───────────────────\n"

# Get WiFi networks
if [ "$AIRPLANE_MODE" = "enabled" ]; then
    NETWORKS=$(nmcli -t -f active,ssid,signal,security dev wifi list | sort -t: -k3 -rn)
    
    while IFS=: read -r active ssid signal security; do
        # Signal strength icon
        if [ "$signal" -ge 75 ]; then
            ICON="󰤨"
        elif [ "$signal" -ge 50 ]; then
            ICON="󰤥"
        elif [ "$signal" -ge 25 ]; then
            ICON="󰤢"
        else
            ICON="󰤟"
        fi
        
        # Security icon
        if [ -n "$security" ]; then
            SEC_ICON="󰌾"
        else
            SEC_ICON=""
        fi
        
        # Current network indicator
        if [ "$active" = "yes" ]; then
            MENU+="󰸞 $ICON  $ssid  $SEC_ICON ($signal%)\n"
        else
            MENU+="  $ICON  $ssid  $SEC_ICON ($signal%)\n"
        fi
    done <<< "$NETWORKS"
fi

# Show menu
CHOICE=$(echo -e "$MENU" | rofi -dmenu -i -p "  WiFi" -theme-str 'window {width: 500px;}' -theme-str 'listview {lines: 12;}')

# Handle selection
case "$CHOICE" in
    *"Airplane Mode"*)
        if [ "$AIRPLANE_MODE" = "enabled" ]; then
            nmcli radio wifi off
        else
            nmcli radio wifi on
        fi
        ;;
    *"Disconnect"*)
        nmcli connection down id "$CURRENT_WIFI"
        notify-send "WiFi" "Disconnected from $CURRENT_WIFI"
        ;;
    *"Refresh"*)
        nmcli dev wifi rescan
        "$0"
        ;;
    *"Ethernet"*)
        # Show ethernet details
        ETH_INFO=$(nmcli dev show "$CURRENT_ETH")
        notify-send "Ethernet" "$ETH_INFO"
        ;;
    *)
        if [ -n "$CHOICE" ]; then
            # Extract SSID from choice
            SSID=$(echo "$CHOICE" | sed 's/^.*  //' | sed 's/  .*//' | xargs)
            
            # Check if network requires password
            SECURITY=$(nmcli -t -f ssid,security dev wifi list | grep "^$SSID:" | cut -d':' -f2)
            
            if [ -n "$SECURITY" ]; then
                # Prompt for password
                PASSWORD=$(rofi -dmenu -password -p "  Password for $SSID")
                if [ -n "$PASSWORD" ]; then
                    nmcli dev wifi connect "$SSID" password "$PASSWORD" && \
                        notify-send "WiFi" "Connected to $SSID" || \
                        notify-send "WiFi" "Failed to connect to $SSID"
                fi
            else
                # Connect without password
                nmcli dev wifi connect "$SSID" && \
                    notify-send "WiFi" "Connected to $SSID" || \
                    notify-send "WiFi" "Failed to connect to $SSID"
            fi
        fi
        ;;
esac
