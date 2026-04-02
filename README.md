# Fire TV Cube Wolf Launcher Watchdog

Non-root automation system that enforces a child-safe launcher on Fire OS using ADB and an external watchdog.

Author: Sean Conroy  
Project type: DevOps / Automation / Systems Integration (small-scale)  
Platform: Fire TV Cube + Raspberry Pi  
Status: Stable, running continuously in a home production environment

---

## Overview

This project solves a real-world limitation in Fire OS by enforcing a child-safe launcher without root access or firmware modification.

Fire OS aggressively promotes its default launcher, including autoplay trailers and promotional content that cannot be fully disabled through system settings — even with child profiles enabled.

To address this, a lightweight external control system was designed:

- A Raspberry Pi acts as a persistent automation agent
- ADB is used to observe the active foreground application in real time
- A watchdog script enforces the desired launcher state

Whenever the Fire OS launcher appears, it is immediately replaced with Wolf Launcher.  
All other applications (e.g. Netflix, Disney+, Apple TV+) remain unaffected.

The result is a stable, non-invasive control loop that maintains a clean, child-safe interface under restrictive platform conditions.

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
## Runtime Characteristics

- Polling interval: 1 second
- Reaction time: <1s
- Runs continuously on Raspberry Pi
- No noticeable impact on device performance

## System Behavior

- Detects currently focused application via ADB
- If Fire OS launcher is active → immediately relaunches Wolf Launcher
- If any other app is active → no action taken
- Runs continuously with minimal resource usage

---

## Disclaimer

This project does not modify Fire OS, bypass DRM, alter firmware, or interfere with content protection mechanisms.

All interactions are performed using documented Android developer tools (ADB) over the local network.

All streaming applications referenced are used with valid, legally obtained subscriptions.

This repository is provided for educational and demonstrative purposes, focusing on automation, observability, and system reliability under platform constraints.


