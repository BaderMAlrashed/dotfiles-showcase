#!/bin/bash

CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print int($2)}')
RAM_USAGE=$(free | awk '/Mem/ {printf("%d"), $3/$2 * 100.0}')
CPU_TEMP=$(sensors | grep -m 1 'Package id 0:' | awk '{print int($4)}' | tr -d '+°C')

TEXT="󰘚"

TOOLTIP="CPU: ${CPU_USAGE}%\nTEMP: ${CPU_TEMP}°C\nRAM: ${RAM_USAGE}%"

echo "{\"text\":\"$TEXT\", \"tooltip\":\"$TOOLTIP\"}"
