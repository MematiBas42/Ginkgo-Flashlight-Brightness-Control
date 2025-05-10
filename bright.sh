#!/system/bin/sh

# --- Configuration ---
# Device-specific paths (usually correct)
CUSTOM_BRIGHTNESS="/sys/class/leds/led:torch_0/custom_brightness"
BRIGHTNESS="/sys/class/leds/flashlight/brightness"

# Paths for persistence
SERVICE_D_DIR="/data/adb/service.d"
SERVICE_SCRIPT_NAME="99permanent_flashlight_brightness.sh" # 99 prefix for late execution
SERVICE_SCRIPT_PATH="$SERVICE_D_DIR/$SERVICE_SCRIPT_NAME"
CONFIG_FILE="/data/adb/flashlight_brightness.conf" # Stores the set brightness
# --- End Configuration ---

# Root check
if ! su -c "true" 2>/dev/null; then
    echo "Root access required!"
    exit 1
fi

# Function to setup the service.d script
setup_service() {
    # Create service.d directory if it doesn't exist
    if ! su -c "[ -d $SERVICE_D_DIR ]"; then
        echo "Creating directory $SERVICE_D_DIR..."
        su -c "mkdir -p $SERVICE_D_DIR"
        if ! su -c "[ -d $SERVICE_D_DIR ]"; then
             echo "ERROR: Failed to create directory $SERVICE_D_DIR!"
             exit 1
        fi
    fi

    # Create the service script if it doesn't exist
    if ! su -c "[ -f $SERVICE_SCRIPT_PATH ]"; then
        echo "Creating $SERVICE_SCRIPT_PATH..."
        # Write the script content using heredoc
        su -c "cat <<'EOF' > $SERVICE_SCRIPT_PATH
#!/system/bin/sh

# Wait a bit for the system to fully boot (ensure sysfs is ready)
sleep 20

# Check if config file and sysfs path exist
if [ -f \"$CONFIG_FILE\" ] && [ -e \"$CUSTOM_BRIGHTNESS\" ]; then
    # Read the saved brightness value
    SAVED_BRIGHTNESS=\$(cat \"$CONFIG_FILE\")

    # Check if the value is a valid number (0-255)
    if echo \"\$SAVED_BRIGHTNESS\" | grep -qE '^[0-9]+$'; then
        if [ \"\$SAVED_BRIGHTNESS\" -ge 0 ] && [ \"\$SAVED_BRIGHTNESS\" -le 255 ]; then
            # Apply the brightness value
            echo \"\$SAVED_BRIGHTNESS\" > \"$CUSTOM_BRIGHTNESS\"
            log -t FlashlightBrightness \"Persistent brightness set to \$SAVED_BRIGHTNESS.\"
        else
             log -t FlashlightBrightness \"ERROR: Saved brightness value (\$SAVED_BRIGHTNESS) is not within 0-255.\"
        fi
    else
        log -t FlashlightBrightness \"ERROR: Saved brightness value (\$SAVED_BRIGHTNESS) is not a valid number.\"
    fi
else
    log -t FlashlightBrightness \"ERROR: Config file ($CONFIG_FILE) or sysfs path ($CUSTOM_BRIGHTNESS) not found.\"
fi

exit 0
EOF"
        # Make the script executable
        su -c "chmod +x $SERVICE_SCRIPT_PATH"
        echo "Service script created and made executable."
    fi
}

# --- Main Script ---

# Ensure the persistent service is set up
setup_service

# Main loop
clear
while true; do
    # Only get the current value needed for display
    current_val=$(su -c "cat $CUSTOM_BRIGHTNESS" 2>/dev/null)
    # Removed flashlight_state and saved_val retrieval as they are no longer displayed

    echo "--- Flashlight Brightness Control ---"
    echo "Current Active Brightness: $current_val"
    # Removed "Saved Persistent Brightness" display
    # Removed "Flashlight Status" display
    echo ""
    echo "Options:"
    echo "[0-255] - Set new persistent brightness value"
    echo "on      - Turn Flashlight ON"
    echo "off     - Turn Flashlight OFF"
    echo "e       - Exit Script"
    echo ""
    echo -n "Your choice: "
    read input

    case $input in
        e)
            echo "Exiting script..."
            exit 0
            ;;
        on)
            # Turn on using the brightness file
            su -c "echo 1 > $BRIGHTNESS"
            echo "Flashlight TURNED ON"
            sleep 1
            clear
            ;;
        off)
            su -c "echo 0 > $BRIGHTNESS"
            echo "Flashlight TURNED OFF"
            sleep 1
            clear
            ;;
        *)
            # Check if input is a number between 0 and 255
            if echo "$input" | grep -qE '^[0-9]+$' && [ "$input" -ge 0 ] && [ "$input" -le 255 ]; then
                valid=1
            else
                valid=0
            fi

            if [ "$valid" -eq 1 ]; then
                # Set the new value and save it persistently
                echo "Setting and saving brightness to $input..."
                su -c "echo $input > $CUSTOM_BRIGHTNESS"
                su -c "echo $input > $CONFIG_FILE" # Write to persistent file

                # Force toggle flashlight off then on to apply the new brightness setting
                su -c "echo 0 > $BRIGHTNESS"
                sleep 0.1 # Short delay
                su -c "echo 1 > $BRIGHTNESS"
                echo "New brightness value applied & flashlight turned ON."

                sleep 1 # Pause before clearing screen
                clear
            else
                clear
                echo "Invalid input! Please enter one of the following:"
                echo "  - A number between 0 and 255"
                echo "  - 'on' (Turn flashlight on)"
                echo "  - 'off' (Turn flashlight off)"
                echo "  - 'e' (Exit)"
                echo ""
            fi
            ;;
    esac
done
