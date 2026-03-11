#!/bin/bash
# =======================
# Sway Status Script
# =======================

# for Hemmah app
get_campaign() {
    ~/Links/Hemmah/src/hemmah-prompt.sh 2>/dev/null || echo ""
}

get_volume() {
    # Get volume percentage
    vol=$(wpctl get-volume @DEFAULT_SINK@ 2>/dev/null | awk '{print int($2*100)}')
    
    if [ -z "$vol" ]; then
        echo "N/A"
        return
    fi
    
    # Detect device type
    device_name=$(wpctl inspect @DEFAULT_SINK@ 2>/dev/null | grep -E "node.nick|node.description" | head -n1 | cut -d'"' -f2)
    
    # Check if it's laptop speakers (internal/device) or external (anything)
    if echo "$device_name" | grep -qiE "speaker|internal|laptop|built-in"; then
        device="d" # Device (laptop speakers)
    else
        device="a" # Anything else (external/bluetooth)
    fi
    
    echo "${vol}%/${device}"
}

get_mic_status() {
    # Get default source (microphone) volume
    mic_vol=$(wpctl get-volume @DEFAULT_SOURCE@ 2>/dev/null)
    
    if echo "$mic_vol" | grep -q "MUTED"; then
        echo "MUTE"
    elif [ -n "$mic_vol" ]; then
        echo "MIC"
    else
        echo "NO-MIC"
    fi
}

get_camera_status() {
    # Check if any video device is in use
    if lsof /dev/video* 2>/dev/null | grep -q video; then
        echo "CAM"
    else
        echo "NO-CAM"
    fi
}

get_net() {
    # Get active interface name
    interface=$(ip route | grep default | awk '{print $5}' | head -n1)
    
    if [ -z "$interface" ]; then
        echo "Disconnected"
        return
    fi
    
    # Get connection type (WiFi or Ethernet)
    if [ -d "/sys/class/net/$interface/wireless" ]; then
        # If WiFi, get network name
        network_name=$(iw dev "$interface" link | grep SSID | awk '{print $2}')
        connection_type="WiFi"
    else
        network_name="Wired"
        connection_type="Eth"
    fi
    
    # Test internet quality
    if ping -c 1 -W 1 8.8.8.8 &>/dev/null; then
        quality="#"
    else
        quality=""
    fi
    
    # Print result
    echo "$interface $network_name $quality"
}

get_battery() {
    capacity=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null)
    status=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null)
    if [ -z "$capacity" ]; then
        echo "No Battery"
    else
        echo "Batt: $capacity% ($status)"
    fi
}

# Initial quick display
echo '{"version":1}'
echo '['
echo '[],'

# Cache for slow operations
wifi=""
battery=""
campaign=""
mic_status=""
cam_status=""
counter=5
campaign_counter=3600
mic_counter=1
cam_counter=2

while true; do
    # Volume and datetime update every cycle (fast)
    volume=$(get_volume)
    datetime=$(date '+%d/%m %a %I:%M %p')
    
    # WiFi and battery update every 5 seconds
    if [ $counter -ge 5 ]; then
        wifi=$(get_net)
        battery=$(get_battery)
        counter=0
    fi

    # Mic status update every 1 second
    if [ $mic_counter -ge 1 ]; then
        mic_status=$(get_mic_status)
        mic_counter=0
    fi

    # Camera status update every 2 seconds
    if [ $cam_counter -ge 2 ]; then
        cam_status=$(get_camera_status)
        cam_counter=0
    fi

    # Campaign update every hour
    if [ $campaign_counter -ge 3600 ]; then
        campaign=$(get_campaign)
        campaign_counter=0
    fi

    
    status_text="Vol: $volume | $mic_status • $cam_status | $battery | $wifi | $datetime |$campaign"
    
    # Output JSON for swaybar
    echo "[{\"full_text\":\"$status_text\"}],"
    
    # Increment counters
    counter=$((counter + 1))
    mic_counter=$((mic_counter + 1))
    cam_counter=$((cam_counter + 1))
    campaign_counter=$((campaign_counter + 1))
    
    sleep 1
done
