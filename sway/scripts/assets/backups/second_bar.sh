#!/bin/bash
# =======================
# System + Sensors Status Bar
# =======================

get_cpu_temp() {
    temp=$(sensors | grep -i 'package id 0' | awk '{print $4}' | sed 's/+//;s/°C//' | cut -d'.' -f1)
    
    if [ -z "$temp" ]; then
        temp=$(sensors | grep -i 'core 0' | awk '{print $3}' | sed 's/+//;s/°C//' | head -n1 | cut -d'.' -f1)
    fi
    
    if [ -z "$temp" ]; then
        echo "N/A"
        return
    fi
    
    if [ "$temp" -gt 75 ]; then
        echo "${temp}°C [B]"
    else
        echo "${temp}°C [G]"
    fi
}

get_cpu_usage() {
    usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
    usage_int=$(echo $usage | cut -d'.' -f1)
    
    if [ "$usage_int" -gt 80 ]; then
        echo "CPU: ${usage}% [B]"
    else
        echo "CPU: ${usage}% [G]"
    fi
}

get_ram_usage() {
    ram_info=$(free | grep Mem)
    total=$(echo $ram_info | awk '{print $2}')
    used=$(echo $ram_info | awk '{print $3}')
    
    percentage=$((used * 100 / total))
    
    if [ "$percentage" -gt 85 ]; then
        echo "RAM: ${percentage}% [B]"
    else
        echo "RAM: ${percentage}% [G]"
    fi
}

get_network_status() {
    if ip link | grep -q "state UP"; then
        echo "Net: ON"
    else
        echo "Net: OFF"
    fi
}

get_bluetooth_status() {
    # Check bluetoothd process directly
    if pgrep -x bluetoothd >/dev/null; then
        if bluetoothctl show 2>/dev/null | grep -q "Powered: yes"; then
            echo "BT: ON"
        else
            echo "BT: OFF"
        fi
    else
        echo "BT: N/A"
    fi
}
# for systemd oses
#get_bluetooth_status() {
#    if systemctl is-active --quiet bluetooth.service; then
#        if bluetoothctl show | grep -q "Powered: yes"; then
#            echo "BT: ON"
#        else
#            echo "BT: OFF"
#        fi
#    else
#        echo "BT: N/A"
#    fi
#}

get_microphone_status() {
    if pactl list sources | grep -q "alsa_input"; then
        echo "Mic: ON"
    else
        echo "Mic: OFF"
    fi
}

get_camera_status() {
    if ls /dev/video* >/dev/null 2>&1; then
        echo "Cam: ON"
    else
        echo "Cam: OFF"
    fi
}

# Initial display
echo '{"version":1}'
echo '['
echo '[],'

cpu_temp=""
cpu_usage=""
ram_usage=""
network=""
bluetooth=""
microphone=""
camera=""
counter=5

while true; do
    datetime=$(date '+%d/%m %I:%M %p')
    
    # Update every 5 seconds
    if [ $counter -ge 5 ]; then
        cpu_temp=$(get_cpu_temp)
        cpu_usage=$(get_cpu_usage)
        ram_usage=$(get_ram_usage)
        network=$(get_network_status)
        bluetooth=$(get_bluetooth_status)
        microphone=$(get_microphone_status)
        camera=$(get_camera_status)
        counter=0
    fi
    
    status_text="$camera | $microphone | $bluetooth | $network | $ram_usage | $cpu_usage | Temp: $cpu_temp | $datetime"
    
    echo "[{\"full_text\":\"$status_text\"}],"
    
    counter=$((counter + 1))
    sleep 1
done
