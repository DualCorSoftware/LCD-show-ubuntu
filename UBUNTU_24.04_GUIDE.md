# Ubuntu 24.04 Support Guide for LCD-show-ubuntu

## Overview

This guide provides detailed instructions for using XPT2046 TFT LCD displays with **Ubuntu 24.04 LTS** on Raspberry Pi (3, 4, and 5).

The LCD-show-ubuntu driver set has been updated to fully support Ubuntu 24.04, including:
- Automatic Ubuntu 24.04 detection
- Modern kernel (6.8+) compatibility
- Device tree overlay support
- Improved error handling and diagnostics

---

## Prerequisites

### Required Hardware
- **Raspberry Pi 3, 4, or 5** (64-bit ARM recommended)
- **XPT2046-based TFT LCD display** (various sizes supported: 2.4", 2.8", 3.2", 3.5", 4.0", 5", 7")
- **MicroSD card** with Ubuntu 24.04 installed
- **Power supply** (appropriate for your Pi model)

### Required Software
1. **Ubuntu 24.04 Server or Desktop** for Raspberry Pi
   - Download from: https://ubuntu.com/download/raspberry-pi
   - Use the 64-bit ARM version for best compatibility

2. **Raspberry Pi kernel with fbtft support**
   ```bash
   sudo apt-get update
   sudo apt-get install linux-modules-extra-raspi
   ```

3. **Internet connection** (for initial setup and package installation)

---

## Installation Steps

### Step 1: Verify Kernel Module Availability

Before installing the LCD driver, check if the required kernel modules are available:

```bash
cd LCD-show-ubuntu
sudo ./check_kernel_modules.sh
```

This script will check for:
- `fbtft` - Framebuffer driver framework
- `fb_ili9486` - ILI9486 LCD controller driver
- `ads7846` - XPT2046/ADS7846 touchscreen driver
- `spi_bcm2835` - Broadcom SPI controller
- Device tree overlay support

**Expected Output:**
```
✓ fbtft - Available
✓ ads7846 - Available
✓ spi_bcm2835 - Available
✓ Device tree overlay directory exists
✓ Boot configuration file exists
```

**If modules are missing**, install them:
```bash
sudo apt-get update
sudo apt-get install linux-modules-extra-raspi linux-image-raspi
sudo reboot
```

### Step 2: Choose Your Display Model

Identify your LCD model and run the corresponding installation script:

| Display Model | Script Command | Resolution | Touch Type |
|--------------|----------------|------------|------------|
| 3.5" GPIO (MPI3501) | `sudo ./LCD35-show` | 480x320 | Resistive |
| 3.5" High Speed (MHS35) | `sudo ./MHS35-show` | 480x320 | Resistive |
| 3.2" High Speed (MHS32) | `sudo ./MHS32-show` | 320x240 | Resistive |
| 4.0" HDMI (MPI4008) | `sudo ./MPI4008-show` | 480x800 | Resistive |
| 5" HDMI | `sudo ./LCD5-show` | 800x480 | Resistive |
| 7" HDMI (1024x600) | `sudo ./LCD7C-show` | 1024x600 | Capacitive |
| 2.4" GPIO | `sudo ./MHS24-show` | 320x240 | Resistive |

### Step 3: Run the Installation Script

For example, to install a 3.5" GPIO LCD:

```bash
cd LCD-show-ubuntu
sudo ./LCD35-show
```

**Installation Process:**
1. ✓ Backs up current configuration
2. ✓ Detects Ubuntu version and architecture
3. ✓ Checks kernel module availability
4. ✓ Configures X11 display settings
5. ✓ Installs device tree overlay
6. ✓ Configures framebuffer driver
7. ✓ Updates boot configuration
8. ✓ Configures touchscreen calibration
9. ✓ Installs touch input driver
10. ✓ Reboots system

### Step 4: Wait for Reboot

The system will automatically reboot. After reboot:
- The LCD display should become active
- Touchscreen should be functional
- HDMI output will be disabled (for GPIO displays)

---

## Troubleshooting

### Display Not Working After Reboot

#### 1. Check Kernel Modules
```bash
sudo ./check_kernel_modules.sh
```

Verify that all required modules are available. If not, install:
```bash
sudo apt-get install linux-modules-extra-raspi
sudo reboot
```

#### 2. Verify SPI Interface
```bash
ls -l /dev/spidev*
```

Expected output:
```
crw-rw---- 1 root spi 153, 0 Nov 12 10:00 /dev/spidev0.0
crw-rw---- 1 root spi 153, 1 Nov 12 10:00 /dev/spidev0.1
```

If SPI devices are missing, check boot configuration:
```bash
grep "dtparam=spi" /boot/firmware/config.txt
```

Should show: `dtparam=spi=on`

#### 3. Check Boot Configuration
```bash
cat /boot/firmware/config.txt
```

Verify these lines are present:
```
dtparam=i2c_arm=on
dtparam=spi=on
enable_uart=1
dtoverlay=tft35a:rotate=90  # (or your specific display overlay)
```

Also verify that `vc4-fkms-v3d` is commented out:
```
# dtoverlay=vc4-fkms-v3d
```

#### 4. Check Framebuffer Device
```bash
ls -l /dev/fb*
```

Expected output:
```
crw-rw---- 1 root video 29, 0 Nov 12 10:00 /dev/fb0  # HDMI
crw-rw---- 1 root video 29, 1 Nov 12 10:00 /dev/fb1  # LCD
```

Test the framebuffer:
```bash
sudo cat /dev/urandom > /dev/fb1  # Should show static on LCD
# Press Ctrl+C to stop
```

#### 5. Check X11 Configuration
```bash
ls -l /etc/X11/xorg.conf.d/
```

Should show:
- `99-calibration.conf` - Touchscreen calibration
- `99-fbturbo.conf` - Framebuffer configuration (in `/usr/share/X11/xorg.conf.d/`)

#### 6. Check Kernel Logs
```bash
sudo dmesg | grep -i "fb\|spi\|ads7846\|ili9486"
```

Look for:
- `ili9486` driver initialization
- `ads7846` touchscreen detection
- `fb1` framebuffer creation
- SPI bus initialization

### Touchscreen Not Working

#### 1. Verify Touch Device
```bash
ls -l /dev/input/event*
sudo evtest
```

Select the touchscreen device (usually "ADS7846 Touchscreen") and test touch response.

#### 2. Check Calibration
```bash
cat /etc/X11/xorg.conf.d/99-calibration.conf
```

Recalibrate if needed:
```bash
sudo apt-get install xinput-calibrator
DISPLAY=:0 xinput_calibrator
```

#### 3. Re-run Installation
If calibration is wrong for your Ubuntu version:
```bash
sudo ./LCD35-show  # Or your specific display script
```

### Display Shows Wrong Orientation

Rotate the display:
```bash
sudo ./rotate.sh 0    # 0 degrees (landscape)
sudo ./rotate.sh 90   # 90 degrees (portrait)
sudo ./rotate.sh 180  # 180 degrees (inverted landscape)
sudo ./rotate.sh 270  # 270 degrees (inverted portrait)
```

The system will reboot automatically to apply rotation.

### Restore HDMI Output

To disable the LCD and restore HDMI:
```bash
sudo ./LCD-hdmi
```

The system will reboot with HDMI as primary display.

---

## Ubuntu 24.04 Specific Notes

### Kernel Differences

Ubuntu 24.04 ships with **Linux kernel 6.8** (or newer), which includes:
- Updated `fbtft` driver framework
- Improved SPI performance
- Better device tree overlay support
- Enhanced touch input handling

### Boot Configuration

Ubuntu 24.04 uses a unified boot process:
```
kernel=vmlinuz
initramfs initrd.img followkernel
```

This is different from Ubuntu 20.04 which used:
```
kernel=uboot_rpi_3.bin  # (separate for each Pi model)
```

The updated `system_config.sh` automatically detects Ubuntu 24.04 and uses the correct boot configuration.

### KMS Graphics

Ubuntu 24.04 defaults to **KMS (Kernel Mode Setting)** graphics:
```
dtoverlay=vc4-kms-v3d
```

**Important:** This overlay is incompatible with fbtft drivers and will be automatically disabled during LCD installation. The LCD driver uses legacy framebuffer mode.

### SPI Module Auto-loading

On Ubuntu 24.04, SPI modules may be auto-loaded. Verify with:
```bash
lsmod | grep spi
```

Expected output:
```
spi_bcm2835            16384  0
```

---

## Performance Optimization

### 1. Disable Unnecessary Services

For headless LCD-only systems, disable HDMI services:
```bash
sudo systemctl disable lightdm  # If using GUI
```

### 2. Increase SPI Speed

Edit device tree parameters in `/boot/firmware/config.txt`:
```
dtoverlay=tft35a:rotate=90,speed=32000000
```

Valid speeds: `16000000`, `32000000` (default: varies by display)

### 3. Adjust CPU Governor

For better performance:
```bash
echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
```

Make permanent:
```bash
sudo apt-get install cpufrequtils
echo 'GOVERNOR="performance"' | sudo tee /etc/default/cpufrequtils
```

---

## Advanced Configuration

### Manual Device Tree Overlay Installation

If automatic installation fails, manually copy the overlay:

```bash
sudo cp usr/tft35a-overlay-20.10.dtb /boot/firmware/overlays/tft35a.dtbo
```

Then add to `/boot/firmware/config.txt`:
```
dtoverlay=tft35a:rotate=90
```

### Custom Calibration

For precise touchscreen calibration:

1. Install calibrator:
```bash
sudo apt-get install xinput-calibrator
```

2. Run calibration:
```bash
DISPLAY=:0 xinput_calibrator
```

3. Copy output to `/etc/X11/xorg.conf.d/99-calibration.conf`:
```
Section "InputClass"
    Identifier "calibration"
    MatchProduct "ADS7846 Touchscreen"
    Option "Calibration" "3936 227 268 3880"
    Option "SwapAxes" "0"
EndSection
```

4. Restart X server or reboot

### Dual Display (LCD + HDMI)

To use both LCD and HDMI simultaneously:

1. Edit `/boot/firmware/config.txt`, keep `vc4-fkms-v3d` enabled:
```
dtoverlay=vc4-fkms-v3d
dtoverlay=tft35a:rotate=90
max_framebuffers=2
```

2. Configure X11 for multiple displays in `/etc/X11/xorg.conf`:
```
Section "ServerLayout"
    Identifier "Default"
    Screen 0 "HDMI"
    Screen 1 "LCD" RightOf "HDMI"
EndSection
```

**Note:** Dual display support is experimental and may not work with all display models.

---

## Differences from Raspberry Pi OS

If you're migrating from Raspberry Pi OS (Raspbian), note these differences:

| Aspect | Raspberry Pi OS | Ubuntu 24.04 |
|--------|----------------|--------------|
| Boot partition | `/boot/` | `/boot/firmware/` |
| Kernel | Custom Pi kernel | Mainline kernel with Pi patches |
| Overlay loading | Direct | Through u-boot (earlier) or direct (24.04) |
| Python default | Python 3.11 | Python 3.12 |
| SystemD | Modified | Standard |
| Package repos | Raspbian repos | Ubuntu repos |

### Package Name Differences

| Raspberry Pi OS | Ubuntu 24.04 |
|----------------|--------------|
| `raspberrypi-kernel` | `linux-image-raspi` |
| `raspberrypi-kernel-headers` | `linux-headers-raspi` |
| `raspi-config` | Not available (manual config) |

---

## Supported Display Models

### GPIO-Connected Displays
- **LCD24-show** - 2.4" 320x240 resistive touch
- **LCD28-show** - 2.8" 320x240 resistive touch
- **LCD32-show** - 3.2" 320x240 resistive touch
- **LCD35-show** - 3.5" 480x320 resistive touch (MPI3501)
- **MHS24-show** - 2.4" 320x240 high-speed resistive touch
- **MHS32-show** - 3.2" 320x240 high-speed resistive touch
- **MHS35-show** - 3.5" 480x320 high-speed resistive touch
- **MHS40-show** - 4.0" 480x320 high-speed resistive touch
- **MIS35-show** - 3.5" 480x320 IPS resistive touch

### HDMI-Connected Displays (with SPI touch)
- **LCD5-show** - 5" 800x480 HDMI resistive touch
- **MPI4008-show** - 4.0" 480x800 HDMI resistive touch
- **LCD7B-show** - 7" 800x480 HDMI capacitive touch
- **LCD7C-show** - 7" 1024x600 HDMI capacitive touch

---

## FAQ

### Q: Does this work with Raspberry Pi 5?
**A:** Yes! Ubuntu 24.04 supports Raspberry Pi 5. The driver includes Pi 5 support in the boot configuration. However, ensure you have the latest kernel:
```bash
sudo apt-get update
sudo apt-get upgrade
```

### Q: Can I use this with Ubuntu 24.10?
**A:** Yes, Ubuntu 24.10 is supported with the same configuration as 24.04.

### Q: Will this work with the 32-bit version of Ubuntu?
**A:** Technically yes, but 32-bit Ubuntu is not officially supported on newer Raspberry Pi models. We strongly recommend using 64-bit Ubuntu 24.04.

### Q: Does this affect GPIO pins?
**A:** Yes, GPIO-connected displays use several GPIO pins:
- **SPI pins**: GPIO 7-11 (SPI0)
- **Additional pins**: Varies by display model
- Check your display's documentation for specific pin usage

### Q: Can I use this with a desktop environment?
**A:** Yes! Tested with:
- **Ubuntu Server** + manual X11 install
- **XFCE** (lightweight, recommended)
- **LXDE** (very lightweight)
- **GNOME** (may be slow on smaller displays)

### Q: What about Wayland?
**A:** Wayland is not supported with fbtft drivers. You must use X11. Ubuntu 24.04 Desktop defaults to Wayland, so you'll need to:
1. Switch to X11 session at login
2. Or use Ubuntu Server with X11 manually installed

### Q: Can I revert the changes?
**A:** Yes! The installation creates a backup:
```bash
sudo ./system_restore.sh
```

Or restore HDMI output:
```bash
sudo ./LCD-hdmi
```

---

## Getting Help

### Check System Status
Run the diagnostic script:
```bash
sudo ./check_kernel_modules.sh
```

### Collect Debug Information
```bash
# System info
uname -a
lsb_release -a

# Kernel modules
lsmod | grep -E "spi|fb|ads"

# Device tree
ls -l /boot/firmware/overlays/*.dtbo

# Framebuffer
ls -l /dev/fb*

# SPI
ls -l /dev/spi*

# Kernel log
sudo dmesg | tail -50
```

### Report Issues
When reporting issues, include:
1. Raspberry Pi model
2. Ubuntu version (`lsb_release -a`)
3. Kernel version (`uname -r`)
4. Display model
5. Output from `check_kernel_modules.sh`
6. Relevant `dmesg` output

---

## Additional Resources

- **Ubuntu for Raspberry Pi**: https://ubuntu.com/raspberry-pi
- **Raspberry Pi Documentation**: https://www.raspberrypi.com/documentation/
- **Device Tree Overlays**: https://www.kernel.org/doc/html/latest/devicetree/
- **fbtft Driver**: https://github.com/notro/fbtft

---

## License

This project maintains the same license as the original LCD-show project.

---

## Changelog

### Version 2024.11 - Ubuntu 24.04 Support
- ✓ Added Ubuntu 24.04 LTS detection
- ✓ Added Ubuntu 24.10 support
- ✓ Created 64-bit config template for Ubuntu 24.04
- ✓ Fixed missing 20.10-64 config file
- ✓ Added kernel module availability checks
- ✓ Improved error handling and user feedback
- ✓ Added comprehensive diagnostics script
- ✓ Updated installation scripts with progress indicators
- ✓ Added Raspberry Pi 5 support in boot configuration
- ✓ Improved fallback handling for future Ubuntu versions
