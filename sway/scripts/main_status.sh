#!/bin/bash
# =======================
# Sway Status Script
# =======================

# for Hemmah app
get_campaign() {
    ~/Links/Hemmah/src/HemmahAssets/hemmah-prompt.sh 2>/dev/null || echo ""
}

get_volume() {
    vol=$(wpctl get-volume @DEFAULT_SINK@ 2>/dev/null | awk '{print int($2*100)}')
    
    if [ -z "$vol" ]; then
        echo "N/A"
        return
    fi
    
    device_name=$(wpctl inspect @DEFAULT_SINK@ 2>/dev/null | grep -E "node.nick|node.description" | head -n1 | cut -d'"' -f2)
    
    if echo "$device_name" | grep -qiE "speaker|internal|laptop|built-in"; then
        device="d"
    else
        device="a"
    fi
    
    echo "${vol}%/${device}"
}

get_mic_status() {
    if ! pactl list sources | grep -q "alsa_input"; then
        echo "NO-MIC"
    elif wpctl get-volume @DEFAULT_SOURCE@ 2>/dev/null | grep -q "MUTED"; then
        echo "MIC:MUTE"
    else
        echo "MIC"
    fi
}

get_camera_status() {
    if ! ls /dev/video* >/dev/null 2>&1; then
        echo "NO-CAM"
    elif lsof /dev/video* 2>/dev/null | grep -q video; then
        echo "CAM:LIVE"
    else
        echo "CAM:IDLE"
    fi
}

get_net() {
    interface=$(ip route | grep default | awk '{print $5}' | head -n1)
    
    if [ -z "$interface" ]; then
        echo "Disconnected"
        return
    fi
    
    if [ -d "/sys/class/net/$interface/wireless" ]; then
        network_name=$(iw dev "$interface" link | grep SSID | awk '{print $2}')
        first=$(echo "$network_name" | cut -c1)
        last=$(echo "$network_name" | awk '{print substr($0,length($0),1)}')
        network_name="${first}.${last}"
    else
        network_name="Wired"
    fi
    
    if ping -c 1 -W 1 8.8.8.8 &>/dev/null; then
        quality="#"
    else
        quality=""
    fi
    
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
    volume=$(get_volume)
    datetime=$(date '+%d/%m %a %I:%M %p')
    
    if [ $counter -ge 5 ]; then
        wifi=$(get_net)
        battery=$(get_battery)
        counter=0
    fi

    if [ $mic_counter -ge 1 ]; then
        mic_status=$(get_mic_status)
        mic_counter=0
    fi

    if [ $cam_counter -ge 2 ]; then
        cam_status=$(get_camera_status)
        cam_counter=0
    fi

    if [ $campaign_counter -ge 3600 ]; then
        campaign=$(get_campaign)
        campaign_counter=0
    fi

    status_text="Vol: $volume | $mic_status | $cam_status | $battery | $wifi | $datetime |$campaign"
    
    echo "[{\"full_text\":\"$status_text\"}],"
    
    counter=$((counter + 1))
    mic_counter=$((mic_counter + 1))
    cam_counter=$((cam_counter + 1))
    campaign_counter=$((campaign_counter + 1))
    
    sleep 1
done
