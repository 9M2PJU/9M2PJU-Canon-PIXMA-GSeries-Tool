# Canon PIXMA G3010 Linux Driver & Maintenance Suite 🖨️

[![AUR package](https://img.shields.io/aur/version/canon-pixma-g3010-tool.svg)](https://aur.archlinux.org/packages/canon-pixma-g3010-tool)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)
[![Platform: Linux](https://img.shields.io/badge/Platform-CachyOS%20%7C%20Arch%20%7C%20Ubuntu%20%7C%20Debian%20%7C%20Fedora-orange.svg)]()
[![Author: 9M2PJU](https://img.shields.io/badge/Author-9M2PJU-green.svg)](https://github.com/9M2PJU)

A Linux driver setup, network routing fix, and interactive maintenance suite for the **Canon PIXMA G3010 Series** (and compatible G-series MegaTank printers: G1000, G1010, G2000, G2010, G3000, G4000, G4010).

This suite gives you full feature parity with the official Windows **Canon IJ Printer Assistant Tool**, including automated sequential head cleaning, real-time digital ink telemetry, auto-alignment, paper path cleaning, and hardware error code documentation.

---

## Table of Contents

- [Why This Project Exists](#why-this-project-exists)
- [How It Works](#how-it-works)
- [Features](#features)
- [Interactive Menu Preview](#interactive-menu-preview)
- [Quick Installation](#quick-installation)
- [Manual Setup Guide](#manual-setup-guide)
- [How to Use](#how-to-use)
- [Understanding Ink Levels on G-Series Printers](#understanding-ink-levels-on-g-series-printers)
- [Hardware Button LCD Code Reference](#hardware-button-lcd-code-reference)
- [Network Troubleshooting](#network-troubleshooting)
- [Uninstallation](#uninstallation)
- [License](#license)

---

## Why This Project Exists

On Microsoft Windows, Canon bundles the *Canon IJ Printer Assistant Tool*, giving users one-click access to head cleanings, nozzle checks, roller cleans, and alignment routines.

On Linux, users typically face three major hurdles:
1. **Outdated Drivers:** Canon's official proprietary Linux driver (`cnijfilter2`) relies on legacy `libxml2.so.2` binaries that fail on modern rolling distributions (Arch Linux, CachyOS, Fedora).
2. **Network Routing Drops:** The printer frequently advertises an IPv4 Link-Local Auto-IP address (`169.254.x.x`) or IPv6 link-local scope that Linux drops unless explicit link-local routes are active.
3. **No GUI Maintenance App:** Standard CUPS web and print dialogs expose basic print settings but lack access to Deep Cleaning, Ink Flush, Roller Cleaning, Bottom Plate Cleaning, and Ink Counter resets.

This tool solves all three issues out of the box.

---

## How It Works

```
┌────────────────────────────────────────────────────────┐
│              User / Desktop Application                │
│   (canon-pixma-g3010-tool GUI / CLI | App Launcher)    │
└───────────┬────────────────────────────────┬───────────┘
            │                                │
            ▼                                ▼
┌───────────────────────┐        ┌───────────────────────┐
│     CUPS Spooler      │        │      IPP Queries      │
│ (lsb/usr/canong3010)  │        │  (Live Ink Telemetry) │
└───────────┬───────────┘        └───────────┬───────────┘
            │                                │
            ▼                                ▼
┌────────────────────────────────────────────────────────┐
│               Local Network Connection                 │
│      (socket://169.254.108.236:9100 | Port 631 IPP)   │
└───────────────────────────┬────────────────────────────┘
                            │
                            ▼
┌────────────────────────────────────────────────────────┐
│            Canon PIXMA G3010 MegaTank Device           │
│   (Print Heads | Scanner Glass | Embedded Remote UI)   │
└────────────────────────────────────────────────────────┘
```

1. **Driver Integration:** Installs Canon's native raster filter pipeline while linking missing shared libraries (`libxml2.so.16 -> libxml2.so.2`).
2. **Network Connection:** Connects directly to the printer over RAW AppSocket (`socket://<IP>:9100`) and IPP (`ipp://<IP>:631/ipp/print`).
3. **Link-Local Routing:** Ensures NetworkManager retains the `169.254.0.0/16` routing table entry so the printer remains reachable across reboots.
4. **Maintenance Injection:** Sends raw `#CUPS-COMMAND` control payloads (`Clean all`, `PrintSelfTestPage`, `com.canon.autoalignment`) directly into the CUPS filter chain.

---

## Features

- **⭐ All-In-One Continuous Maintenance Routine:**
  Runs an automated 5-stage sequential workflow:
  `Initial Baseline Nozzle Check` &rarr; `Print Head Cleaning (60s purge)` &rarr; `Verification Nozzle Check` &rarr; `Auto-Alignment Sheet` &rarr; `Guided Paper Path Cleaning`.
- **📊 Real-Time Digital Ink Levels:**
  Queries live IPP printer markers and renders visual progress bars in your terminal.
- **🧼 Print Head Maintenance:**
  Instant execution of Standard Cleaning, Deep Cleaning, and Ink Flush (system tube recharge).
- **📐 Print Head Alignment:**
  Automated print calibration sheets and optical scanner glass alignment.
- **🧻 Paper Path & Mechanical Cleaning:**
  Step-by-step interactive workflows for Paper Feed Rollers and Bottom Plate anti-smudge cleaning.
- **🌐 Embedded Web UI Integration:**
  Direct launcher to the printer's internal web configuration portal.
- **📖 Hardware Codes Cheat Sheet:**
  Comprehensive reference guide for all physical LCD panel codes.
- **🚀 Desktop Launcher:**
  Integrated `.desktop` file compatible with Rofi, Wofi, KDE Plasma, GNOME, and XFCE.

---

## Interactive Menu Preview

```text
==================================================================
    Canon PIXMA G3010 - Assistant & Maintenance Utility
==================================================================
 ⭐ 0) ALL-IN-ONE CONTINUOUS ROUTINE (Runs 1 to 5 sequentially)
------------------------------------------------------------------
 [Print Head & Ink Maintenance]
  1) Nozzle Check Pattern           (Checks for clogged nozzles)
  2) Cleaning                       (Standard print head cleaning)
  3) Deep Cleaning                  (Cleans stubborn clogs)
  4) Ink Flush                      (Purges tubes & fills heads)
  5) Print Head Alignment           (Corrects misalignment & lines)
  6) Remaining Ink Levels & Reset   (Live IPP check & reset guide)

 [Paper & Mechanical Cleaning]
  7) Roller Cleaning                (Cleans paper feed rollers)
  8) Bottom Plate Cleaning          (Cleans interior paper smudges)

 [Device Management & Settings]
  9) Printer Web Remote UI          (Quiet mode, Auto-power, Ink stats)
 10) CUPS Printer Status            (http://localhost:631)
 11) Complete Hardware Codes Reference
  q) Quit
==================================================================
```

---

## Quick Installation

### Option A: Install from AUR (Arch / CachyOS / Manjaro)
```bash
yay -S canon-pixma-g3010-tool
# or
paru -S canon-pixma-g3010-tool
```

### Option B: Automated Installer Script (All Distributions)
```bash
git clone https://github.com/9M2PJU/9M2PJU-Canon-PIXMA-G3010-Linux-Tool.git
cd 9M2PJU-Canon-PIXMA-G3010-Linux-Tool
chmod +x install.sh bin/canon-pixma-g3010-tool
./install.sh
```

The installer detects your distribution, installs required dependencies, fixes shared libraries, configures the network route, sets up the CUPS queue, and registers the desktop launcher.

---

## Manual Setup Guide

If you prefer to configure the system manually:

### 1. Install Dependencies
* **Arch Linux / CachyOS / Manjaro:**
  ```bash
  sudo pacman -S cups cups-filters gutenprint foomatic-db-gutenprint-ppds avahi nss-mdns python python-gobject gtk3
  yay -S cnijfilter2-g3010
  ```
* **Debian / Ubuntu:**
  ```bash
  sudo apt update
  sudo apt install cups cups-filters printer-driver-gutenprint avahi-daemon python3 python3-gi gir1.2-gtk-3.0
  ```

### 2. Fix Legacy Library Symlink
On modern Linux systems with `libxml2 >= 2.14`:
```bash
sudo ln -sf /usr/lib/libxml2.so.16 /usr/lib/libxml2.so.2
```

### 3. Ensure Link-Local Wi-Fi Routing
If your printer uses Link-Local Auto-IP (`169.254.x.x`):
```bash
sudo nmcli con modify "<Your-WiFi-Name>" ipv4.link-local 1 +ipv4.routes "169.254.0.0/16"
sudo nmcli con up "<Your-WiFi-Name>"
```

### 4. Configure CUPS Queue
```bash
sudo systemctl enable --now cups.service avahi-daemon.service
sudo lpadmin -p Canon_G3010 -E -v "socket://169.254.108.236:9100" -m "lsb/usr/canong3010.ppd"
sudo lpadmin -d Canon_G3010
```

### 5. Install the Maintenance Utility
```bash
sudo mkdir -p /usr/share/cmdtocanonij2
sudo cp data/cmdtocanonij2/*.utl /usr/share/cmdtocanonij2/
sudo cp bin/canon-pixma-g3010-tool /usr/local/bin/canon-pixma-g3010-tool
sudo chmod +x /usr/local/bin/canon-pixma-g3010-tool
sudo cp desktop/canon-pixma-g3010-tool.desktop /usr/local/share/applications/
```

---

## How to Use

### 1. Graphical User Interface (Default GUI)
Launch the native GTK3 graphical assistant:
```bash
canon-pixma-g3010-tool
```
* Or search for **Canon PIXMA G3010 Tool** in your desktop application launcher / Rofi / Wofi.

### 2. Terminal TUI Mode (Headless / SSH)
If you prefer running inside the terminal or over SSH:
```bash
canon-pixma-g3010-tool --cli
```

### 3. Direct Command Line Invocations
```bash
# Print Nozzle Check Pattern
lp -d Canon_G3010 /usr/share/cmdtocanonij2/nozzlecheck.utl

# Trigger Print Head Cleaning
lp -d Canon_G3010 /usr/share/cmdtocanonij2/cleaning.utl

# Trigger Auto-Alignment Sheet
lp -d Canon_G3010 /usr/share/cmdtocanonij2/autoalign.utl
```

---

## Understanding Ink Levels on G-Series Printers

The Canon G3010 is a **MegaTank Continuous Ink Supply System (CISS)**.

```
 ┌─────────────┐                      ┌─────────────┐
 │  [BK Tank]  │                      │ [C] [M] [Y] │
 │ ─────────── │ <-- Upper Limit Line │ ─────────── │
 │             │     (Full Capacity)  │             │
 │             │                      │             │
 │   ● ● ● ●   │ <-- Lower Limit Dot  │   ● ● ● ●   │
 └─────────────┘     (Refill Point)   └─────────────┘
```

### Key Differences:
1. **No Physical Sensors:** There are no electronic float sensors inside the ink tanks. The printer cannot measure the physical liquid level.
2. **Software Dot Counter:** The printer tracks ink consumption by counting micro-droplets fired during printing. Digital readings will show `100%` until thousands of pages are printed.
3. **Physical Windows Are Primary:** Always visually check the ink level through the front transparent windows.
4. **Refill Point:** Always refill bottles before the liquid drops below the **single dot (`●`) mark**.
5. **Resetting the Counter:** When refilling ink to the upper line, reset the software counter:
   * **Quick Reset:** Press and hold the **[Stop]** button (red triangle in circle) for **5 seconds**.
   * **Menu Code:** Press `[Setup / 🔧]` until `8` appears on the LCD &rarr; press `[Black]` or `[Color]`.

---

## Hardware Button LCD Code Reference

Use these codes for standalone operation directly from the printer panel:

| LCD Code | Function | Instructions |
| :---: | :--- | :--- |
| **`1`** | **Nozzle Check Pattern** | Press `🔧` until `1` &rarr; press `[Black]` or `[Color]`. |
| **`2`** | **Standard Head Cleaning** | Press `🔧` until `2` &rarr; press `[Black]` or `[Color]`. |
| **`3`** | **Deep Head Cleaning** | Press `🔧` until `3` &rarr; press `[Black]` or `[Color]`. |
| **`4`** | **Print Alignment Sheet** | Press `🔧` until `4` &rarr; press `[Black]` or `[Color]`. |
| **`5`** | **Scan Alignment Calibration** | Place alignment sheet face down on glass &rarr; press `🔧` until `5` &rarr; press `[Color]`. |
| **`6`** | **Roller Cleaning** | Empty rear tray &rarr; press `🔧` until `6` &rarr; press `[Color]` (rollers spin dry) &rarr; load 3 sheets &rarr; press `[Color]`. |
| **`7`** | **Bottom Plate Cleaning** | Fold 1 A4 sheet half widthwise & unfold &rarr; load with crease facing you &rarr; press `🔧` until `7` &rarr; press `[Color]`. |
| **`8`** | **Ink Counter Reset** | Press `🔧` until `8` &rarr; press `[Black]` (for Black tank) or `[Color]` (for Color tanks). |
| **`10`** | **Ink Flush (System Purge)** | ⚠️ Verify ink &ge; 50% &rarr; press `🔧` until `10` &rarr; press `[Color]`. (10 minute cycle). |
| **`11`** | **Print Network Config** | Press `🔧` until `11` &rarr; press `[Black]` or `[Color]` (prints IP, MAC, and Serial Number). |

---

## Network Troubleshooting

### 1. Printer is unreachable / ping fails
* The G3010 frequently defaults to Link-Local IPv4 (`169.254.x.x`).
* Ensure your network interface has link-local routing enabled:
  ```bash
  sudo ip route add 169.254.0.0/16 dev wlan1
  ```
* Test port responses:
  ```bash
  nc -zv 169.254.108.236 9100 631 80
  ```

### 2. Embedded Web Remote UI
* Open `http://169.254.108.236` (or your printer's IP) in Google Chrome.
* **Default Username:** `ADMIN` (or `admin`)
* **Default Password:** Your printer's **Serial Number** (e.g. `KPGR58063` found on the rear label or printed via Code `11`).

### 3. Firewall Rules
Ensure your firewall permits local printer traffic:
* `9100/tcp` (JetDirect RAW print)
* `631/tcp` (IPP print & status)
* `515/tcp` (LPD)
* `5353/udp` (mDNS / Avahi discovery)

---

## Uninstallation

To remove the tools, scripts, and CUPS configuration:

```bash
cd 9M2PJU-Canon-PIXMA-G3010-Linux-Tool
./uninstall.sh
```

---

## License

This project is licensed under the [GNU General Public License v3.0 (GPLv3)](LICENSE).

Authored by **[9M2PJU](https://github.com/9M2PJU)**.
Contributions and improvements are welcome via pull requests!
