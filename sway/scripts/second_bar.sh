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

get_disk_usage() {
    df -h / | awk 'NR==2 {print "Disk: "$4}'
}

get_hijri() {
    result=$(curl -sL --max-time 3 "https://api.aladhan.com/v1/gToH?date=$(date +%d-%m-%Y)" 2>/dev/null | \
        python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)['data']['hijri']
    print(f\"{d['day']} {d['month']['en']} {d['year']} AH\")
except:
    pass
" 2>/dev/null)
    echo "$result"
}

# Initial display
echo '{"version":1}'
echo '['
echo '[],'

cpu_temp=""
cpu_usage=""
ram_usage=""
disk=""
hijri=""
counter=5
disk_counter=30
# يتحدث مرة كل ساعة (3600 ثانية)
hijri_counter=3600

while true; do
    datetime=$(date '+%I:%M %p')
    
    if [ $counter -ge 5 ]; then
        cpu_temp=$(get_cpu_temp)
        cpu_usage=$(get_cpu_usage)
        ram_usage=$(get_ram_usage)
        counter=0
    fi

    if [ $disk_counter -ge 30 ]; then
        disk=$(get_disk_usage)
        disk_counter=0
    fi

    if [ $hijri_counter -ge 3600 ]; then
        hijri=$(get_hijri)
        hijri_counter=0
    fi

    # لو مفيش نت، مش بيظهر التاريخ الهجري خالص
    if [ -n "$hijri" ]; then
        status_text="ILOVEU | $disk | $ram_usage | $cpu_usage | Temp: $cpu_temp | $hijri $datetime "
    else
        status_text="ILOVEU | $disk | $ram_usage | $cpu_usage | Temp: $cpu_temp | $datetime "
    fi
    
    echo "[{\"full_text\":\"$status_text\"}],"
    
    counter=$((counter + 1))
    disk_counter=$((disk_counter + 1))
    hijri_counter=$((hijri_counter + 1))
    sleep 1
done
