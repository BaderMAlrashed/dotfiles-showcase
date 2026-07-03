#!/bin/bash

DATE_EN=$(date "+%A, %d %B %Y")
TIME=$(date "+%H:%M:%S")

CAL_EN=$(cal)

# escape newlines for JSON
CAL_EN_ESCAPED=$(echo "$CAL_EN" | sed ':a;N;$!ba;s/\n/\\n/g')

TOOLTIP="🕒 $DATE_EN  $TIME\n\n📅 Calendar:\n$CAL_EN_ESCAPED"

echo "{\"text\":\"\", \"tooltip\":\"$TOOLTIP\"}"
