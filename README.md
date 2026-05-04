# ⚠️ WIP
---

<h1 align="center">
  <br>
  <img src="https://raw.githubusercontent.com/Shim06/Anemoia/main/assets/Anemoia.png" alt="Anemoia" width="150">
  <br>
  <b>Anemoia-PiZero</b>
  <br>
</h1>

<p align="center">
  Anemoia-PiZero is a fork of <a href="https://github.com/Shim06/Anemoia-ESP32">Anemoia-ESP32</a>, adapted to run on a <strong>Raspberry Pi Zero</strong> using <strong>RetroPie</strong>.  
  It reuses the original 3D-printed enclosure and tactile button layout, replacing the ESP32 with a Pi Zero and dropping the battery for a USB-powered build.  
  The display is an ILI9341-based SPI TFT (240×320), driven via the Pi's SPI interface.
</p>

---

## Table of Contents

- [Differences from Anemoia-ESP32](#differences-from-anemoia-esp32)
- [Hardware Overview](#hardware-overview)
  - [Parts List](#parts-list)
  - [Wiring](#wiring)
    - [ILI9341 Display](#ili9341-display)
    - [Tactile Buttons](#tactile-buttons)
- [Software Setup](#software-setup)
  - [Step 1 - Install RetroPie](#step-1---install-retropie)
  - [Step 2 - Configure the SPI Display](#step-2---configure-the-spi-display)
  - [Step 3 - Configure GPIO Buttons](#step-3---configure-gpio-buttons)
  - [Step 4 - Add ROMs](#step-4---add-roms)
- [3D Model & Enclosure](#3d-model--enclosure)
- [Contributing](#contributing)
- [License](#license)

---

## Differences from Anemoia-ESP32

| Aspect            | Anemoia-ESP32               | Anemoia-PiZero                        |
|-------------------|-----------------------------|---------------------------------------|
| Board             | ESP32 (dual-core)           | Raspberry Pi Zero (no W)              |
| OS / Runtime      | Arduino / bare metal        | RetroPie (Raspberry Pi OS + RetroArch)|
| Display           | ST7789 or ILI9341 SPI TFT   | ILI9341 SPI TFT (240×320)             |
| Audio             | PAM8403 amplifier + speaker | None (not implemented yet)            |
| ROM storage       | Separate SPI microSD module | ROMs on the main OS SD card           |
| Input             | Various controllers         | 8 tactile push buttons (GPIO)         |
| Power             | Battery + TP4056 charger    | USB power only (no battery)           |
| PCB               | Custom PCB options          | Hand-wired (wires / proto board)      |

---

## Hardware Overview

### Parts List

- Raspberry Pi Zero (any revision; Pi Zero 2 W recommended for better performance)
- ILI9341-based SPI TFT display, 240×320
- 8 tactile push buttons
- MicroSD card (for OS + ROMs)
- USB power supply (5V / 1A minimum via micro-USB)
- Wires for hand-wiring (no PCB required)

> [!NOTE]
> No audio amplifier or speaker is needed for this build. Audio support may be added in a future revision.

---

### Wiring

![Anemoia-PiZero Wiring Diagram](hardware/Anemoia-PiZero/wiring/Anemoia-PiZero-Wiring.svg)

All connections are hand-wired. The Pi Zero uses 3.3V logic on all GPIO pins, which is directly compatible with the ILI9341 display.

#### ILI9341 Display

The display is connected to the Pi Zero's hardware SPI0 bus.

| ILI9341 Signal | Pi Zero Pin | GPIO  |
|----------------|-------------|-------|
| VCC            | Pin 17      | 3.3V  |
| GND            | Pin 20      | GND   |
| CS             | Pin 24      | GPIO8 (CE0) |
| RESET          | Pin 22      | GPIO25 |
| DC / RS        | Pin 18      | GPIO24 |
| MOSI / SDI     | Pin 19      | GPIO10 (MOSI) |
| SCK / CLK      | Pin 23      | GPIO11 (SCLK) |
| LED / BL       | Pin 17      | 3.3V (always on) |
| MISO           | -           | Not connected |

> [!NOTE]
> The backlight (LED/BL) pin can be connected directly to 3.3V for always-on operation, or to a GPIO pin if you want software brightness control later.

---

#### Tactile Buttons

Each button connects between a GPIO pin and GND. The Pi's internal pull-up resistors are enabled in software.

| NES Button | Pi Zero Pin | GPIO   |
|------------|-------------|--------|
| A          | Pin 29      | GPIO5  |
| B          | Pin 31      | GPIO6  |
| Up         | Pin 33      | GPIO13 |
| Down       | Pin 35      | GPIO19 |
| Left       | Pin 36      | GPIO16 |
| Right      | Pin 38      | GPIO20 |
| Start      | Pin 40      | GPIO21 |
| Select     | Pin 37      | GPIO26 |

> [!NOTE]
> These GPIO assignments are suggestions. You can remap them during the RetroArch controller configuration step. Avoid GPIO2, GPIO3 (I2C), and GPIO14/15 (UART) to prevent conflicts.

---

## Software Setup

### Step 1 - Install RetroPie

1. Download the latest **RetroPie** image for **Raspberry Pi Zero / Zero W** from the [official RetroPie website](https://retropie.org.uk/download/).
2. Flash the image to your microSD card using [Raspberry Pi Imager](https://www.raspberrypi.com/software/) or [balenaEtcher](https://etcher.balena.io/).
3. Insert the SD card into your Pi Zero and boot it up connected to an HDMI monitor first to complete initial setup.

---

### Step 2 - Configure the SPI Display

The ILI9341 display is driven via the kernel's `fbtft` framebuffer driver, enabled through a device tree overlay.

1. Mount the SD card on your PC, or SSH/edit directly on the Pi, and open `/boot/config.txt`.

2. Add the following lines at the end of the file:

```
# Enable SPI
dtparam=spi=on

# ILI9341 display via fbtft
dtoverlay=fbtft,spi0-0,ili9341,speed=32000000,fps=60,bgr=1,reset_pin=25,dc_pin=24,rotate=90
```

3. To redirect the framebuffer output from the HDMI (`/dev/fb0`) to the SPI display (`/dev/fb1`), install `fbcp`:

```bash
sudo apt update
sudo apt install -y cmake
git clone https://github.com/tasanakorn/rpi-fbcp
cd rpi-fbcp
mkdir build && cd build
cmake ..
make
sudo install fbcp /usr/local/bin/fbcp
```

4. Make `fbcp` start at boot by adding it to `/etc/rc.local` before `exit 0`:

```bash
fbcp &
```

5. Set the resolution to match the display in `/boot/config.txt`:

```
hdmi_group=2
hdmi_mode=87
hdmi_cvt=320 240 60 1 0 0 0
hdmi_force_hotplug=1
```

6. Reboot. The RetroPie interface should appear on the SPI display.

> [!NOTE]
> `bgr=1` corrects the blue/red channel swap common on ILI9341 modules. Remove it if colours look correct without it.

---

### Step 3 - Configure GPIO Buttons

RetroPie uses `mk_arcade_joystick_rpi` (or `GPIOnext`) to expose GPIO buttons as a gamepad to RetroArch.

#### Install mk_arcade_joystick_rpi

```bash
# From the RetroPie-Setup script:
# Main Menu → Manage Packages → Manage driver packages → gpio-joystick → Install
```

Or manually:

```bash
git clone https://github.com/recalbox/mk_arcade_joystick_rpi
cd mk_arcade_joystick_rpi
sudo ./install.sh
```

#### Load the module with your GPIO mapping

Map the buttons to the GPIO numbers you wired. The order expected by `mk_arcade_joystick_rpi` is:

`up, down, left, right, start, select, a, b`

Using the pin assignments from the [Tactile Buttons](#tactile-buttons) table above:

```bash
sudo modprobe mk_arcade_joystick_rpi map=1 gpio=13,19,16,20,21,26,5,6
```

To make this permanent, add to `/etc/modules`:

```
mk_arcade_joystick_rpi
```

And create `/etc/modprobe.d/mk_arcade_joystick_rpi.conf`:

```
options mk_arcade_joystick_rpi map=1 gpio=13,19,16,20,21,26,5,6
```

#### Configure RetroArch

On first launch, EmulationStation will prompt you to configure the controller. Press and hold any button to begin, then follow the on-screen mapping.

---

### Step 4 - Add ROMs

1. Copy your legally obtained `.nes` ROM files to the following directory on the SD card:

```
/home/pi/RetroPie/roms/nes/
```

You can do this by:
- Mounting the SD card on your PC and copying files directly, or
- Using a USB drive: create a folder `retropie/roms/nes/` on the USB drive, plug it into the Pi, wait 30 seconds, then copy ROMs to the populated folder.

2. Restart EmulationStation. Your ROMs will appear in the NES game list.

---

## 3D Model & Enclosure

The original enclosure and 3D models from Anemoia-ESP32 are reused unchanged. All files are available in the `/3d-model` folder.

> [!NOTE]
> The Pi Zero has the same compact form factor as the ESP32 DevKit used in the original design. Minor modifications to the PCB mount points may be required depending on your specific Pi Zero revision. The hand-wired approach means no custom PCB is needed.

---

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

---

## License

This project is licensed under the GNU General Public License v3.0 (GPLv3) - see the [LICENSE](LICENSE) file for more details.

Original Anemoia-ESP32 project by [Shim06](https://github.com/Shim06/Anemoia-ESP32).
