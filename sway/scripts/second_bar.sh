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

# Initial display
echo '{"version":1}'
echo '['
echo '[],'

cpu_temp=""
cpu_usage=""
ram_usage=""
counter=5

while true; do
    datetime=$(date '+%d/%m %I:%M %p')
    
    if [ $counter -ge 5 ]; then
        cpu_temp=$(get_cpu_temp)
        cpu_usage=$(get_cpu_usage)
        ram_usage=$(get_ram_usage)
        counter=0
    fi
    
    status_text="ILOVEU | $ram_usage | $cpu_usage | Temp: $cpu_temp | $datetime "
    
    echo "[{\"full_text\":\"$status_text\"}],"
    
    counter=$((counter + 1))
    sleep 1
done
