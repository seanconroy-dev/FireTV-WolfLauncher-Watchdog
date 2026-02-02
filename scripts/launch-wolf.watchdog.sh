#!/bin/bash
# launch_wolf_watchdog.sh
#
# Replace the placeholders below with your real values:
# - DEVICE_IP: your Fire TV device IP
# - WOLF_PKG:  Wolf Launcher package name (example: com.wolf.firelauncher)
# - FIRE_PKG:  Fire TV Home launcher package name (example: com.amazon.tv.launcher)

DEVICE_IP="192.168.XXX.XXX"
WOLF_PKG="com.wolf.firelauncher"
FIRE_PKG="com.amazon.tv.launcher"

# Quiet connect (ignore output)
adb connect "$DEVICE_IP" >/dev/null 2>&1

while true; do
  FOREGROUND=$(
    adb -s "$DEVICE_IP" shell "dumpsys window | grep mCurrentFocus" \
      | grep -oP 'com\.[\w\.]+' \
      | head -1 \
      | tr -d '\r'
  )

  echo "[DEBUG] Foreground: '$FOREGROUND'"

  if [[ "$FOREGROUND" == "$FIRE_PKG" ]]; then
    echo "[INFO] Fire Launcher detected, launching Wolf..."
    adb -s "$DEVICE_IP" shell monkey -p "$WOLF_PKG" -c android.intent.category.LAUNCHER 1 >/dev/null 2>&1
  fi

  sleep 1
done
