#!/bin/bash
usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
ram_info=$(free | grep Mem)
total=$(echo $ram_info | awk '{print $2}')
used=$(echo $ram_info | awk '{print $3}')
echo "RAM: $((used * 100 / total))% | CPU: ${usage}%"
