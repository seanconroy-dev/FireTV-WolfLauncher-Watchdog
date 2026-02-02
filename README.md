# Fire TV Cube Wolf Launcher Watchdog
Non-root automation to enforce a child-safe launcher on Fire OS

Author: Sean Conroy  
Project type: DevOps / Automation / Systems Integration (small-scale)  
Platform: Fire TV Cube + Raspberry Pi  
Status: Stable, running continuously in a home production environment

---

## Overview

This repository documents a real-world automation problem and a practical solution.

Fire OS prominently displays autoplay trailers and promotional thumbnails on the home screen, including content that is not appropriate for children.  
At the time of implementation, Fire OS provided no reliable system-level option to fully disable or filter this behavior, even when using child profiles.

The goal of this project was to **consistently suppress the Fire OS launcher** and **enforce a clean, child-safe launcher (Wolf Launcher)** at all times, without rooting the device or modifying firmware.

The solution uses:
- A Raspberry Pi as an external automation agent
- ADB (Android Debug Bridge) over the local network
- A lightweight bash-based watchdog script that continuously enforces launcher state

---

## Problem Statement

- Fire TV Cube displays inappropriate promotional content on the home screen
- No supported system setting exists to fully disable this behavior
- Third-party launchers are actively deprioritized or blocked by Fire OS
- The system must function unattended, without manual intervention
- The solution must not interfere with normal app usage, including:
  - Netflix
  - Disney+
  - MagentaTV
  - WOW
  - Apple TV+
- No rooting, custom ROMs, or firmware modifications are acceptable

---

## Solution Architecture

### High-level design

Fire TV Cube (Fire OS)  
↓  
ADB over local network  
↓  
Raspberry Pi running a 24/7 watchdog

### Core concept

- Fire OS cannot be replaced, but it can be observed
- ADB allows inspection of the currently focused application
- When the Fire OS launcher is detected, Wolf Launcher is immediately relaunched
- When any other application is active, no action is taken

This creates a simple but effective **control loop** that Fire OS cannot bypass.

---

## Watchdog Script (Core Component)

### launch-wolf.watchdog.sh

```bash
#!/bin/bash

DEVICE_IP="192.168.x.x"
WOLF_PKG="com.wolf.firelauncher"
FIRE_PKG="com.amazon.tv.launcher"

adb connect "$DEVICE_IP" >/dev/null

while true; do
    FOREGROUND=$(adb -s "$DEVICE_IP" shell \
        "dumpsys window | grep mCurrentFocus" \
        | grep -oP 'com\.[\w\.]+' \
        | head -1 \
        | tr -d '\r')

    echo "[DEBUG] Foreground app: '$FOREGROUND'"

    if [[ "$FOREGROUND" == "$FIRE_PKG" ]]; then
        echo "[INFO] Fire OS launcher detected. Relaunching Wolf Launcher."
        adb -s "$DEVICE_IP" shell monkey \
            -p "$WOLF_PKG" \
            -c android.intent.category.LAUNCHER 1
    fi

    sleep 1
done
```

---

## Disclaimer

This project does not modify Fire OS, bypass DRM, alter firmware, or interfere with content protection mechanisms.

All interactions are performed using documented Android developer tools (ADB) over the local network.

All streaming applications referenced are used with valid, legally obtained subscriptions.

This repository is provided for educational and demonstrative purposes, focusing on automation, observability, and system reliability under platform constraints.


