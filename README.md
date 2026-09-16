# Canon PIXMA G3010 Series Linux Assistant & Maintenance Suite 🖨️

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform: Linux](https://img.shields.io/badge/Platform-Linux%20%7C%20CachyOS%20%7C%20Arch%20%7C%20Ubuntu-orange.svg)]()
[![Author: 9M2PJU](https://img.shields.io/badge/Author-9M2PJU-green.svg)](https://github.com/9M2PJU)

A comprehensive driver installer, network configurator, and interactive maintenance suite for the **Canon PIXMA G3010 Series** (MegaTank / Continuous Ink Supply System) on Linux (CachyOS, Arch Linux, Debian, Ubuntu, and Fedora).

Provides full feature parity with the **Canon IJ Printer Assistant Tool on Windows**, including automated continuous cleaning routines, real-time digital ink levels, auto-alignment, and physical hardware maintenance codes.

---

## ✨ Features

- **⭐ All-In-One Continuous Maintenance Routine:** Runs a complete automated sequence: Initial Nozzle Check &rarr; Head Cleaning Purge &rarr; Verification Check &rarr; Head Alignment &rarr; Mechanical Roller/Plate Cleaning.
- **📊 Real-Time Digital Ink Levels:** Queries live IPP markers from the printer and renders clean terminal progress bars.
- **🧼 Print Head Cleaning & Deep Cleaning:** Instant execution of standard and deep head cleaning cycles.
- **📐 Print Head Auto-Alignment:** Prints calibration sheets and guides optical scanning alignment.
- **🧻 Paper Path & Mechanical Cleaning:** Step-by-step guides for Paper Feed Roller cleaning and Bottom Plate anti-smudge cleaning.
- **🎛️ Embedded Web UI Integration:** 1-click launch to the printer's remote management web portal (`http://169.254.108.236`).
- **📖 Complete Hardware Codes Reference:** Explains all 1-digit LCD maintenance codes accessible via the physical `[Setup / 🔧]` button.
- **🚀 Desktop Application Launcher:** Fully integrated `.desktop` entry for Rofi, Wofi, KDE, and GNOME application launchers.

---

## 📸 Interactive Menu Preview

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

## 🚀 Automated Installation

Clone the repository and run the installer:

```bash
git clone https://github.com/9M2PJU/9M2PJU-Canon-PIXMA-G3010-Linux-Tool.git
cd 9M2PJU-Canon-PIXMA-G3010-Linux-Tool
chmod +x install.sh bin/canon-maintenance
./install.sh
```

### What `install.sh` Does Automatically:
1. Installs CUPS, `gutenprint`, `cups-filters`, `avahi`, and official `cnijfilter2-g3010` driver.
2. Fixes legacy library compatibility (`libxml2.so.2 -> libxml2.so.16`).
3. Sets up persistent link-local IPv4 routing (`169.254.0.0/16`) in NetworkManager for wireless connectivity.
4. Adds the CUPS queue `Canon_G3010` and sets it as the default printer.
5. Installs `canon-maintenance` into `/usr/local/bin` and registers the desktop application launcher.

---

## 🖥️ Usage

### 1. Interactive Maintenance App
* **Terminal:**
  ```bash
  canon-maintenance
  ```
* **Application Launcher (Rofi / Wofi / KDE / GNOME):**
  Press `SUPER + Space` and search for **`Canon PIXMA G3010 Maintenance`**.

### 2. Direct CLI Commands
You can trigger individual operations directly without the interactive menu:
```bash
# Print Nozzle Check Pattern
lp -d Canon_G3010 /usr/share/cmdtocanonij2/nozzlecheck.utl

# Standard Print Head Cleaning
lp -d Canon_G3010 /usr/share/cmdtocanonij2/cleaning.utl

# Auto-Alignment Sheet
lp -d Canon_G3010 /usr/share/cmdtocanonij2/autoalign.utl
```

---

## 🔧 Canon PIXMA G3010 Hardware Reference Codes

For standalone operation without a computer, use the **`[Setup / 🔧]`** button on the printer's top panel:

| LCD Code | Function | Instructions |
| :---: | :--- | :--- |
| **`1`** | **Nozzle Check Pattern** | Press `🔧` until `1` &rarr; press `[Black]` or `[Color]`. |
| **`2`** | **Standard Head Cleaning** | Press `🔧` until `2` &rarr; press `[Black]` or `[Color]`. |
| **`3`** | **Deep Head Cleaning** | Press `🔧` until `3` &rarr; press `[Black]` or `[Color]`. |
| **`4`** | **Print Alignment Sheet** | Press `🔧` until `4` &rarr; press `[Black]` or `[Color]`. |
| **`5`** | **Scan Alignment Calibration** | Put alignment sheet face down on glass &rarr; press `🔧` until `5` &rarr; press `[Color]`. |
| **`6`** | **Roller Cleaning** | Empty tray &rarr; press `🔧` until `6` &rarr; press `[Color]` &rarr; load 3 sheets &rarr; press `[Color]` again. |
| **`7`** | **Bottom Plate Cleaning** | Fold 1 A4 sheet half widthwise & unfold &rarr; load with crease facing you &rarr; press `🔧` until `7` &rarr; press `[Color]`. |
| **`8`** | **Remaining Ink Count Reset** | Press `🔧` until `8` &rarr; press `[Black]` (for Black tank) or `[Color]` (for Color tanks). *(Or hold `[Stop]` for 5s).* |
| **`10`** | **Ink Flush (System Purge)** | ⚠️ Ensure ink tanks &ge; 50% &rarr; press `🔧` until `10` &rarr; press `[Color]`. (10 min cycle). |
| **`11`** | **Print Network Config Sheet** | Press `🔧` until `11` &rarr; press `[Black]` or `[Color]`. |

---

## 🌐 Web Remote UI & Default Credentials

* **Web URL:** `http://169.254.108.236` (or `http://4C639F000000.local`)
* **Default Username:** `ADMIN` (or `admin`)
* **Default Password:** The printer's **Serial Number** (e.g. `KPGR58063` located on the rear white barcode label).

---

## 🗑️ Uninstallation

To remove the maintenance tools and configurations:
```bash
./uninstall.sh
```

---

## 📜 License

Released under the [MIT License](LICENSE).  
Authored by **[9M2PJU](https://github.com/9M2PJU)**.
