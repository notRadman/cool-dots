#!/bin/bash
# =======================
# Sway Status Script
# =======================

# for Hemmah app
get_campaign() {
    ~/Links/Hemmah/src/hemmah-prompt.sh 2>/dev/null || echo ""
}

get_volume() {
    wpctl get-volume @DEFAULT_SINK@ | awk '{print int($2*100) "%"}'
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
counter=5
campaign_counter=3600

while true; do
    # Volume and datetime update every cycle (fast)
    volume=$(get_volume)
    datetime=$(date '+%d/%m %a %I:%M %p')
    
    # WiFi, battery and bluetooth update every 5 seconds
    if [ $counter -ge 5 ]; then
        wifi=$(get_net)
        battery=$(get_battery)
        counter=0
    fi

    # Campaign update every hour
    if [ $campaign_counter -ge 3600 ]; then
        campaign=$(get_campaign)
        campaign_counter=0
    fi

    
    status_text="Vol: $volume | $battery | $wifi | $datetime |$campaign"
    
    # Output JSON for swaybar
    echo "[{\"full_text\":\"$status_text\"}],"
    
    # Increment counter
    counter=$((counter + 1))
    
    sleep 1
done
