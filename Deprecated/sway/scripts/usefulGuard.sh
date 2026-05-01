#!/bin/bash

# System Manager Script for Void Linux + Sway/Wayland
# Monitors:
#   - Battery level, health, and charging status
#   - USB devices (flash drives, peripherals, etc.)

#### CONFIGURATION - Edit these values as needed ####

# How often to check battery status (in seconds)
BATTERY_CHECK_INTERVAL=10

# How often to repeat low battery warnings (in seconds)
REPEAT_WARNING_INTERVAL=60

# Battery thresholds for different health levels
THRESHOLD_EXCELLENT=20  # Health > 80%
THRESHOLD_GOOD=25       # Health 70-80%
THRESHOLD_FAIR=30       # Health 60-70%
THRESHOLD_POOR=35       # Health < 60%

# Device monitoring interval (in seconds)
DEVICE_CHECK_INTERVAL=2

# Notification timeout settings (in milliseconds)
# Set to 0 for persistent notifications (stay until clicked)
# Set to any positive number for auto-dismiss after that many milliseconds
TIMEOUT_BATTERY=5000        # Battery notifications (5 seconds)
TIMEOUT_USB=0               # USB device notifications (persistent)

#### SETUP ####

# Get script directory for relative asset paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ASSETS_DIR="$SCRIPT_DIR/assets"

# Sound files (relative to script location)
SOUND_BATTERY_WARNING="$ASSETS_DIR/battery_warning.wav"
SOUND_BATTERY_CRITICAL="$ASSETS_DIR/battery_critical.wav"
SOUND_DEVICE_CONNECTED="$ASSETS_DIR/device_connected.wav"
SOUND_DEVICE_DISCONNECTED="$ASSETS_DIR/device_disconnected.wav"

# State tracking - Battery
LAST_WARNING_TIME=0
LAST_NOT_CHARGING_WARNING=0
PREVIOUS_BATTERY_STATUS=""
NOTIFIED_CHARGING=false

# State tracking - Devices
PREVIOUS_USB_DEVICES=""

#### SHARED FUNCTIONS ####

# Function to play sound
play_sound() {
    local sound_file="$1"
    
    if [[ ! -f "$sound_file" ]]; then
        return
    fi
    
    # Try paplay first (PulseAudio), then aplay (ALSA)
    if command -v paplay &> /dev/null; then
        paplay "$sound_file" 2>/dev/null &
    elif command -v aplay &> /dev/null; then
        aplay "$sound_file" 2>/dev/null &
    fi
}

# Function to send notification
send_notification() {
    local title="$1"
    local message="$2"
    local urgency="${3:-normal}"  # normal, low, critical
    local sound="${4:-}"
    local timeout="${5:-5000}"    # timeout in milliseconds, 0 for persistent
    
    # Send notification using mako/dunst
    if command -v notify-send &> /dev/null; then
        if [[ $timeout -eq 0 ]]; then
            # Persistent notification (stays until clicked)
            notify-send -u "$urgency" -t 0 -a "System Manager" "$title" "$message"
        else
            # Timed notification
            notify-send -u "$urgency" -t "$timeout" -a "System Manager" "$title" "$message"
        fi
    fi
    
    # Play sound if provided
    if [[ -n "$sound" ]]; then
        play_sound "$sound"
    fi
}

#### BATTERY MONITORING FUNCTIONS ####

# Function to get battery path
get_battery_path() {
    local bat_path
    
    # Try to find battery (BAT0, BAT1, etc.)
    for bat in /sys/class/power_supply/BAT*; do
        if [[ -d "$bat" ]]; then
            echo "$bat"
            return 0
        fi
    done
    
    return 1
}

# Function to check if battery exists
battery_exists() {
    get_battery_path &> /dev/null
}

# Function to get battery capacity (percentage)
get_battery_capacity() {
    local bat_path="$1"
    
    if [[ -f "$bat_path/capacity" ]]; then
        cat "$bat_path/capacity"
    else
        echo "0"
    fi
}

# Function to get battery status (Charging, Discharging, Not charging, Full)
get_battery_status() {
    local bat_path="$1"
    
    if [[ -f "$bat_path/status" ]]; then
        cat "$bat_path/status"
    else
        echo "Unknown"
    fi
}

# Function to get battery health (percentage of original capacity)
get_battery_health() {
    local bat_path="$1"
    local health=100
    
    if [[ -f "$bat_path/energy_full" ]] && [[ -f "$bat_path/energy_full_design" ]]; then
        local current_full=$(cat "$bat_path/energy_full")
        local design_full=$(cat "$bat_path/energy_full_design")
        
        if [[ $design_full -gt 0 ]]; then
            health=$((current_full * 100 / design_full))
        fi
    elif [[ -f "$bat_path/charge_full" ]] && [[ -f "$bat_path/charge_full_design" ]]; then
        local current_full=$(cat "$bat_path/charge_full")
        local design_full=$(cat "$bat_path/charge_full_design")
        
        if [[ $design_full -gt 0 ]]; then
            health=$((current_full * 100 / design_full))
        fi
    fi
    
    echo "$health"
}

# Function to determine warning threshold based on battery health
get_warning_threshold() {
    local health="$1"
    
    if [[ $health -ge 80 ]]; then
        echo "$THRESHOLD_EXCELLENT"
    elif [[ $health -ge 70 ]]; then
        echo "$THRESHOLD_GOOD"
    elif [[ $health -ge 60 ]]; then
        echo "$THRESHOLD_FAIR"
    else
        echo "$THRESHOLD_POOR"
    fi
}

# Function to check battery and send warnings
check_battery() {
    local current_time=$(date +%s)
    
    # Check if battery exists
    if ! battery_exists; then
        # No battery detected, running on AC power directly
        return
    fi
    
    local bat_path=$(get_battery_path)
    local capacity=$(get_battery_capacity "$bat_path")
    local status=$(get_battery_status "$bat_path")
    local health=$(get_battery_health "$bat_path")
    local threshold=$(get_warning_threshold "$health")
    
    # Check for charger connected (status changed from Discharging to Charging)
    if [[ "$status" == "Charging" ]] && [[ "$PREVIOUS_BATTERY_STATUS" == "Discharging" ]]; then
        send_notification \
            "⚡ Charger Connected" \
            "Battery at ${capacity}%. Charging now." \
            "normal" \
            "$SOUND_DEVICE_CONNECTED" \
            "$TIMEOUT_BATTERY"
        NOTIFIED_CHARGING=true
    fi
    
    # Check for charger disconnected (status changed from Charging to Discharging)
    if [[ "$status" == "Discharging" ]] && [[ "$PREVIOUS_BATTERY_STATUS" == "Charging" || "$PREVIOUS_BATTERY_STATUS" == "Not charging" ]]; then
        send_notification \
            "🔋 Charger Disconnected" \
            "Battery at ${capacity}%. Running on battery power." \
            "normal" \
            "$SOUND_DEVICE_DISCONNECTED" \
            "$TIMEOUT_BATTERY"
        NOTIFIED_CHARGING=false
    fi
    
    # Check for "Not charging" status (battery full but AC connected)
    if [[ "$status" == "Not charging" ]] && [[ "$PREVIOUS_BATTERY_STATUS" != "Not charging" ]]; then
        # Only notify once when status changes to "Not charging"
        if [[ $((current_time - LAST_NOT_CHARGING_WARNING)) -ge 300 ]]; then
            send_notification \
                "🔋 Battery Full" \
                "Battery is at ${capacity}% and not charging. Consider unplugging to preserve battery health." \
                "normal" \
                "" \
                "$TIMEOUT_BATTERY"
            LAST_NOT_CHARGING_WARNING=$current_time
        fi
    fi
    
    # Check for low battery warnings
    if [[ "$status" == "Discharging" ]] && [[ $capacity -le $threshold ]]; then
        # Battery is low and no charger plugged
        if [[ $((current_time - LAST_WARNING_TIME)) -ge $REPEAT_WARNING_INTERVAL ]]; then
            local urgency="normal"
            local sound="$SOUND_BATTERY_WARNING"
            local health_note=""
            
            # Adjust urgency and sound based on capacity
            if [[ $capacity -le 10 ]]; then
                urgency="critical"
                sound="$SOUND_BATTERY_CRITICAL"
            elif [[ $capacity -le 15 ]]; then
                urgency="critical"
            fi
            
            # Add health note if battery health is degraded
            if [[ $health -lt 80 ]]; then
                health_note=" (Battery health: ${health}%)"
            fi
            
            send_notification \
                "⚠️ Low Battery Warning" \
                "Battery at ${capacity}%${health_note}. Please plug in charger!" \
                "$urgency" \
                "$sound" \
                "$TIMEOUT_BATTERY"
            
            LAST_WARNING_TIME=$current_time
        fi
    fi
    
    # Update previous status
    PREVIOUS_BATTERY_STATUS="$status"
}

#### USB DEVICE MONITORING FUNCTIONS ####

# Function to get list of USB devices with details
get_usb_devices() {
    # Use lsusb to get device list with IDs and names
    lsusb 2>/dev/null | sort
}

# Function to get device name from lsusb output
get_device_name() {
    local line="$1"
    # Extract device name (everything after "ID xxxx:xxxx ")
    echo "$line" | sed -E 's/^Bus [0-9]+ Device [0-9]+: ID [0-9a-f]+:[0-9a-f]+ //'
}

# Function to check USB devices
check_usb_devices() {
    local current_devices=$(get_usb_devices)
    
    # If this is the first run, just store the current state
    if [[ -z "$PREVIOUS_USB_DEVICES" ]]; then
        PREVIOUS_USB_DEVICES="$current_devices"
        return
    fi
    
    # Check for newly connected devices
    while IFS= read -r device; do
        if [[ -n "$device" ]] && ! echo "$PREVIOUS_USB_DEVICES" | grep -Fq "$device"; then
            local device_name=$(get_device_name "$device")
            send_notification \
                "🔌 USB Device Connected" \
                "$device_name" \
                "normal" \
                "$SOUND_DEVICE_CONNECTED" \
                "$TIMEOUT_USB"
        fi
    done <<< "$current_devices"
    
    # Check for disconnected devices
    while IFS= read -r device; do
        if [[ -n "$device" ]] && ! echo "$current_devices" | grep -Fq "$device"; then
            local device_name=$(get_device_name "$device")
            send_notification \
                "🔌 USB Device Disconnected" \
                "$device_name" \
                "normal" \
                "$SOUND_DEVICE_DISCONNECTED" \
                "$TIMEOUT_USB"
        fi
    done <<< "$PREVIOUS_USB_DEVICES"
    
    # Update previous state
    PREVIOUS_USB_DEVICES="$current_devices"
}

#### MAIN LOOP ####

# Initial checks
check_battery
check_usb_devices

# Counters for different check intervals
battery_counter=0
device_counter=0

# Main monitoring loop
while true; do
    sleep 1
    
    battery_counter=$((battery_counter + 1))
    device_counter=$((device_counter + 1))
    
    # Check battery at its interval
    if [[ $battery_counter -ge $BATTERY_CHECK_INTERVAL ]]; then
        check_battery
        battery_counter=0
    fi
    
    # Check devices at their interval
    if [[ $device_counter -ge $DEVICE_CHECK_INTERVAL ]]; then
        check_usb_devices
        device_counter=0
    fi
done
