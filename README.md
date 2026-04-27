# RetroArch One-Click Settings

v1.0 by djparent

A simple one-click configuration script for RetroArch on R36S, designed for ArkOS and dArkOS, applying optimized performance and usability settings across both 32-bit and 64-bit RetroArch configurations.

---

## Overview

This script automatically applies a curated set of RetroArch settings aimed at improving usability, consistency, and performance.

It modifies both standard and 32-bit RetroArch configuration files in a single run.

---

## Features

- Applies settings to both RetroArch and RetroArch32
- Automatic configuration backup-safe edits (no file overwrite)
- Enables save/load quality-of-life improvements
- Organizes saves, states, and screenshots logically
- Enables automatic savestate saving and loading
- Sets optimized UI menu driver (Ozone)
- Configures controller shortcuts for menu and exit
- Enables automatic frame delay tuning
- Improves aspect ratio behavior for handheld display
- Fully automated "run once and done" setup

---

## Applied Settings

### Save System Behavior

- Save configuration on exit enabled  
- Savestates auto-save enabled  
- Savestates auto-load enabled  
- Savefiles sorted by core name  
- Savestates sorted by core name  
- Screenshot sorting enabled  

---

### File Organization

- Savefiles NOT stored in content directory  
- Savestates NOT stored in content directory  
- Screenshots NOT stored in content directory  

---

### Video & Display

- Aspect ratio preset: Core provided 
- Automatic frame delay: ON  

---

### UI & Controls

- Menu driver set to: Ozone  
- Menu toggle gamepad combo: Down + Select  
- Exit emulator combo: Select + Start  

---

## How It Works

### Configuration Files Targeted

The script modifies:

/home/ark/.config/retroarch/retroarch.cfg  
/home/ark/.config/retroarch32/retroarch.cfg  

---

### Edit Method

Each setting is processed using a safe replace-or-append method:

- If the key exists → it is updated  
- If the key does not exist → it is added  

No full config overwrite is performed.

---

### Output

During execution, the script prints progress directly to:

/dev/tty1

This provides real-time feedback on applied settings.

---

## Installation

1. Copy the script to your R36S Tools folder  
2. Run it once  
3. Reboot RetroArch or restart your device if needed  

---

## Requirements

- R36S running ArkOS or dArkOS  
- RetroArch installed (standard paths assumed)  
- sudo/root access (auto-elevates if needed)  

---

## Notes

- Safe to run multiple times  
- Will not duplicate config entries  
- Designed for quick system setup or reset  
- Focused on stability + usability rather than customization UI  
- No external dependencies required  

---

## Credits

- Created by djparent  

---
