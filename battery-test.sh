#!/bin/bash

OUT="${1:-$HOME/battery-test-$(date +%Y%m%d-%H%M%S).csv}"
DEVICE="/org/freedesktop/UPower/devices/DisplayDevice"
START=$(date +%s)

printf 'timestamp,elapsed_minutes,percentage,energy_Wh,power_W,time_to_empty_hours,state\n' > "$OUT"

echo "Logging to: $OUT"
echo "Press Ctrl-C to stop."

while true; do
    NOW=$(date +%s)
    INFO=$(LC_ALL=C upower -i "$DEVICE")

    TIMESTAMP=$(date --iso-8601=seconds)
    ELAPSED=$(( (NOW - START) / 60 ))

    PERCENT=$(awk '/percentage:/ {gsub("%","",$2); print $2}' <<<"$INFO")
    ENERGY=$(awk '/^[[:space:]]*energy:/ {print $2}' <<<"$INFO")
    POWER=$(awk '/energy-rate:/ {print $2}' <<<"$INFO")
    STATE=$(awk '/state:/ {print $2}' <<<"$INFO")

    TTE=$(awk '
        /time to empty:/ {
            if ($4 == "hours")   print $3
            else if ($4 == "minutes") print $3 / 60
            else print ""
        }
    ' <<<"$INFO")

    printf '%s,%s,%s,%s,%s,%s,%s\n' \
        "$TIMESTAMP" "$ELAPSED" "$PERCENT" "$ENERGY" \
        "$POWER" "$TTE" "$STATE" >> "$OUT"

    sleep 60
done
