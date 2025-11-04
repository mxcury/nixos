#!/usr/bin/env bash

# Rofi Wallpaper Chooser

WALLPAPER_DIR="$HOME/.config/nixos/wallpapers"

# Check if directory exists
if [ ! -d "$WALLPAPER_DIR" ]; then
    notify-send "Wallpaper" "Wallpaper directory not found!"
    exit 1
fi

# Get list of wallpapers
WALLPAPERS=$(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.gif" -o -name "*.bmp" \) -printf "%f\n" | sort)

if [ -z "$WALLPAPERS" ]; then
    notify-send "Wallpaper" "No wallpapers found in $WALLPAPER_DIR"
    exit 1
fi

# Get current wallpaper (if tracked)
CURRENT_WALLPAPER_FILE="$HOME/.cache/current_wallpaper"
if [ -f "$CURRENT_WALLPAPER_FILE" ]; then
    CURRENT_WALLPAPER=$(cat "$CURRENT_WALLPAPER_FILE")
else
    CURRENT_WALLPAPER=""
fi

# Build menu with icons and current indicator
MENU=""
MENU+="  Random Wallpaper\n"
MENU+="  Previous Wallpaper\n"
MENU+="  Next Wallpaper\n"
MENU+="───────────────────\n"

while IFS= read -r wallpaper; do
    # Remove extension for display
    DISPLAY_NAME=$(echo "$wallpaper" | sed 's/\.[^.]*$//')
    
    # Format name nicely
    DISPLAY_NAME=$(echo "$DISPLAY_NAME" | sed 's/-/ /g' | sed 's/\b\(.\)/\u\1/g')
    
    if [ "$wallpaper" = "$CURRENT_WALLPAPER" ]; then
        MENU+="󰸞 󰋩  $DISPLAY_NAME (Current)\n"
    else
        MENU+="  󰋩  $DISPLAY_NAME\n"
    fi
done <<< "$WALLPAPERS"

# Show menu with preview (if using rofi with image preview support)
CHOICE=$(echo -e "$MENU" | rofi -dmenu -i -p "  Wallpaper" -theme-str 'window {width: 500px;}' -theme-str 'listview {lines: 12;}')

# Handle selection
if [ -z "$CHOICE" ]; then
    exit 0
fi

# Function to set wallpaper
set_wallpaper() {
    local wallpaper_file="$1"
    local wallpaper_name=$(basename "$wallpaper_file")
    
    # Set wallpaper using swww
    swww img "$wallpaper_file" --transition-type fade --transition-duration 2
    
    # Save current wallpaper
    echo "$wallpaper_name" > "$CURRENT_WALLPAPER_FILE"
    
    # Get display name
    DISPLAY_NAME=$(echo "$wallpaper_name" | sed 's/\.[^.]*$//' | sed 's/-/ /g' | sed 's/\b\(.\)/\u\1/g')
    notify-send "Wallpaper" "Changed to: $DISPLAY_NAME"
}

case "$CHOICE" in
    *"Random Wallpaper"*)
        # Select random wallpaper
        RANDOM_WALLPAPER=$(echo "$WALLPAPERS" | shuf -n 1)
        set_wallpaper "$WALLPAPER_DIR/$RANDOM_WALLPAPER"
        ;;
    *"Previous Wallpaper"*)
        if [ -n "$CURRENT_WALLPAPER" ]; then
            # Get list as array
            WALLPAPER_ARRAY=()
            while IFS= read -r wp; do
                WALLPAPER_ARRAY+=("$wp")
            done <<< "$WALLPAPERS"
            
            # Find current index
            for i in "${!WALLPAPER_ARRAY[@]}"; do
                if [[ "${WALLPAPER_ARRAY[$i]}" = "$CURRENT_WALLPAPER" ]]; then
                    CURRENT_INDEX=$i
                    break
                fi
            done
            
            # Get previous index (wrap around)
            PREV_INDEX=$(( (CURRENT_INDEX - 1 + ${#WALLPAPER_ARRAY[@]}) % ${#WALLPAPER_ARRAY[@]} ))
            set_wallpaper "$WALLPAPER_DIR/${WALLPAPER_ARRAY[$PREV_INDEX]}"
        else
            notify-send "Wallpaper" "No current wallpaper set"
        fi
        ;;
    *"Next Wallpaper"*)
        if [ -n "$CURRENT_WALLPAPER" ]; then
            # Get list as array
            WALLPAPER_ARRAY=()
            while IFS= read -r wp; do
                WALLPAPER_ARRAY+=("$wp")
            done <<< "$WALLPAPERS"
            
            # Find current index
            for i in "${!WALLPAPER_ARRAY[@]}"; do
                if [[ "${WALLPAPER_ARRAY[$i]}" = "$CURRENT_WALLPAPER" ]]; then
                    CURRENT_INDEX=$i
                    break
                fi
            done
            
            # Get next index (wrap around)
            NEXT_INDEX=$(( (CURRENT_INDEX + 1) % ${#WALLPAPER_ARRAY[@]} ))
            set_wallpaper "$WALLPAPER_DIR/${WALLPAPER_ARRAY[$NEXT_INDEX]}"
        else
            # Just pick first one
            FIRST_WALLPAPER=$(echo "$WALLPAPERS" | head -n 1)
            set_wallpaper "$WALLPAPER_DIR/$FIRST_WALLPAPER"
        fi
        ;;
    *)
        if [ "$CHOICE" != *"───"* ]; then
            # Extract wallpaper name from choice
            WALLPAPER_NAME=$(echo "$CHOICE" | sed 's/^[^ ]* *//' | sed 's/ (Current)//' | sed 's/ /\-/g' | tr '[:upper:]' '[:lower:]')
            
            # Find matching wallpaper file
            SELECTED_WALLPAPER=$(echo "$WALLPAPERS" | grep -i "$WALLPAPER_NAME" | head -n 1)
            
            if [ -z "$SELECTED_WALLPAPER" ]; then
                # Try without formatting
                SELECTED_WALLPAPER=$(echo "$WALLPAPERS" | grep -F "$(echo "$CHOICE" | sed 's/.*󰋩  //' | sed 's/ (Current)//')" | head -n 1)
            fi
            
            if [ -n "$SELECTED_WALLPAPER" ]; then
                set_wallpaper "$WALLPAPER_DIR/$SELECTED_WALLPAPER"
            fi
        fi
        ;;
esac
