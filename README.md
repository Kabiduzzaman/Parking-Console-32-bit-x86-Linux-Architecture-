# Parking-Console-32-bit-x86-Linux-Architecture-# 

🚗⚡ EVO Parking — Smart Parking & EV Charging Terminal
> **32-Bit x86 Linux NASM Assembly (`elf_i386`)** | **Low-Level IoT Telemetry & Automated Toll System**

**EVO Parking** is a lightweight, zero-dependency carpark and EV charging management terminal engineered entirely in **32-bit x86 assembly language (NASM)** for Linux. Using direct kernel system calls (`int 0x80`), parallel memory arrays, and custom ASCII-to-binary arithmetic routines, it simulates a real-world embedded parking kiosk with live bay sensors, automated clamping enforcement, itemized receipt printing, and a password-protected administrator portal.

---

### ✨ Key Highlights
* **📡 Live Ultrasonic Bay Telemetry:** Tracks **5 Standard Bays (1–5)** and **2 EV Charging Stations (6–7)** with real-time occupancy states (`[ FREE ]` vs. `[OCCUPIED: Xh]`).
* **🚫 Smart Capacity Pre-Scanning:** Automatically scans bay arrays prior to check-in and halts entry with an apology notice if all Standard or EV bays are full.
* **🧮 3-Tier Tariff & Wheel-Clamping Engine:**
  * **Standard Bays (1–5):** `RM 5/hr` (1–24h) • `RM 10/hr` (25–48h) • **Overstay (>48h):** `RM 480` cap + `RM 100` Clamp Fine (`RM 580`).
  * **EV Charging Bays (6–7):** `RM 8/hr` (1–24h) • `RM 12/hr` (25–48h) • **Overstay (>48h):** `RM 576` cap + `RM 150` EV Clamp Fine (`RM 726`).
* **🧾 Itemized Official Receipt Generator:** Supports **Cash**, **Credit/Debit Card (PayWave)**, and **Touch 'n Go eWallet / DuitNow QR** payments.
* **🔐 Session-Based Admin Control Panel:** Locked behind a single sign-on security gate (`admin` / `1234`) featuring an **IoT Sensor Clock Simulator (`+Hours`)**, **Daily Revenue Tracker**, **Manual Barricade Override**, and a **Customer Feedback Log Viewer**.

---

### 🚀 Quick Start (Linux / GitHub Codespaces)

```bash
# 1. Install NASM and 32-bit GNU linker utilities
sudo apt update && sudo apt install -y nasm binutils

# 2. Assemble and link the 32-bit x86 binary
nasm -f elf32 parking.asm -o parking.o
ld -m elf_i386 parking.o -o parking

# 3. Launch the terminal
./parking
