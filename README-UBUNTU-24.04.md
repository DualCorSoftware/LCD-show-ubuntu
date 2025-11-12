# LCD-show-ubuntu - Ubuntu 24.04 LTS Support

## Quick Start for Ubuntu 24.04

This driver set now **fully supports Ubuntu 24.04 LTS** (Noble Numbat) on Raspberry Pi 3, 4, and 5.

### Installation (3 Steps)

1. **Check prerequisites:**
   ```bash
   sudo apt-get update
   sudo apt-get install linux-modules-extra-raspi
   sudo ./check_kernel_modules.sh
   ```

2. **Run installation for your display:**
   ```bash
   # Example for 3.5" LCD:
   sudo ./LCD35-show

   # Or for your specific model:
   # sudo ./MHS35-show   # 3.5" High Speed
   # sudo ./LCD5-show    # 5" HDMI
   # sudo ./LCD7C-show   # 7" 1024x600 HDMI
   ```

3. **Wait for automatic reboot**

Your LCD should be working after reboot!

---

## What's New in This Version

### Ubuntu 24.04+ Support
- ✅ Automatic Ubuntu 24.04 & 24.10 detection
- ✅ Linux kernel 6.8+ compatibility
- ✅ Raspberry Pi 5 support
- ✅ Improved error handling
- ✅ Kernel module verification

### Enhanced Diagnostics
```bash
sudo ./check_kernel_modules.sh
```

This new script checks:
- Kernel module availability (fbtft, ads7846, spi)
- Device tree overlay support
- Boot configuration
- Provides specific fix recommendations

### Better Installation Experience
- Clear step-by-step progress messages
- Automatic Raspberry Pi detection
- Internet connectivity detection
- Helpful error messages and recovery suggestions

---

## Troubleshooting

### Display not working?

1. **Check modules:**
   ```bash
   sudo ./check_kernel_modules.sh
   ```

2. **Verify SPI:**
   ```bash
   ls /dev/spidev*
   ```

3. **Check framebuffer:**
   ```bash
   ls /dev/fb*  # Should show fb0 and fb1
   ```

4. **View kernel messages:**
   ```bash
   sudo dmesg | grep -i "fb\|spi\|ads7846"
   ```

### Need to restore HDMI?
```bash
sudo ./LCD-hdmi
```

### Change screen rotation?
```bash
sudo ./rotate.sh 0    # 0, 90, 180, or 270 degrees
```

---

## Supported Systems

| OS Version | Status | Notes |
|------------|--------|-------|
| Ubuntu 24.04 LTS | ✅ Fully Supported | Recommended |
| Ubuntu 24.10 | ✅ Fully Supported | |
| Ubuntu 22.04 LTS | ✅ Supported | |
| Ubuntu 20.04 LTS | ✅ Supported | |
| Ubuntu 18.04 LTS | ⚠️ Limited | End of life |

**Architecture:** 64-bit ARM (aarch64) recommended

**Raspberry Pi Models:**
- ✅ Raspberry Pi 5 (with Ubuntu 24.04+)
- ✅ Raspberry Pi 4 Model B
- ✅ Raspberry Pi 3 Model B/B+
- ✅ Raspberry Pi Zero 2 W

---

## Supported Display Models

### GPIO Displays (SPI)
- LCD35-show (3.5" 480x320)
- MHS35-show (3.5" 480x320 High Speed)
- MHS32-show (3.2" 320x240 High Speed)
- MHS24-show (2.4" 320x240 High Speed)
- And more...

### HDMI Displays (with SPI touch)
- LCD5-show (5" 800x480)
- MPI4008-show (4.0" 480x800)
- LCD7C-show (7" 1024x600)
- LCD7B-show (7" 800x480)

---

## Key Technical Changes

### Boot Configuration
Ubuntu 24.04 uses unified kernel boot:
```
kernel=vmlinuz
initramfs initrd.img followkernel
```

### Device Tree Overlays
Automatically selects correct overlay version:
- Ubuntu 20.10+ uses updated DTB format
- Older versions use legacy format

### Kernel Modules
Required modules on Ubuntu 24.04:
```bash
sudo apt-get install linux-modules-extra-raspi
```

This provides:
- `fbtft` - Framebuffer TFT driver framework
- `fb_ili9486` - ILI9486 LCD controller
- `ads7846` - XPT2046/ADS7846 touch controller
- `spi_bcm2835` - BCM SPI driver

---

## Complete Documentation

For detailed information, see:
- **[UBUNTU_24.04_GUIDE.md](UBUNTU_24.04_GUIDE.md)** - Comprehensive guide
  - Detailed installation steps
  - Advanced troubleshooting
  - Performance optimization
  - Custom configuration
  - FAQ and tips

---

## Quick Reference

### Installation Scripts
```bash
# Check system compatibility
sudo ./check_kernel_modules.sh

# Install display driver (choose your model)
sudo ./LCD35-show        # 3.5" GPIO
sudo ./MHS35-show        # 3.5" High Speed GPIO
sudo ./LCD5-show         # 5" HDMI

# Rotate display
sudo ./rotate.sh [0|90|180|270]

# Restore HDMI
sudo ./LCD-hdmi

# Backup/restore
sudo ./system_backup.sh
sudo ./system_restore.sh
```

### Important Files
```
/boot/firmware/config.txt           # Boot configuration
/etc/X11/xorg.conf.d/               # X11 display config
/boot/firmware/overlays/*.dtbo      # Device tree overlays
```

### Kernel Module Check
```bash
# Check if modules are loaded
lsmod | grep -E "fbtft|ads7846|spi_bcm2835"

# Load module manually (if needed)
sudo modprobe fbtft
sudo modprobe ads7846
```

---

## Important Notes for Ubuntu 24.04

1. **Wayland not supported** - Use X11 session
2. **Desktop environment** - XFCE or LXDE recommended for performance
3. **KMS disabled** - vc4-kms-v3d conflicts with fbtft, automatically disabled
4. **Internet required** - For initial package installation
5. **Kernel updates** - May require re-running installation after kernel updates

---

## Getting Help

**Before asking for help:**
1. Run `sudo ./check_kernel_modules.sh`
2. Check kernel logs: `sudo dmesg | tail -50`
3. Verify installation: `ls /boot/firmware/overlays/*.dtbo`

**Include in bug reports:**
- Raspberry Pi model
- Ubuntu version (`lsb_release -a`)
- Kernel version (`uname -r`)
- Display model
- Output from check_kernel_modules.sh

---

## Credits

Original LCD-show repository adapted for Ubuntu with enhanced support for modern versions.

**Maintainers:** Community-driven project

**Testing:** Tested on:
- Ubuntu 24.04 LTS + Raspberry Pi 4 + LCD35
- Ubuntu 24.04 LTS + Raspberry Pi 5 + MHS35
- Ubuntu 22.04 LTS + Raspberry Pi 4 + LCD5

---

## License

Same as original LCD-show project.

**Last Updated:** November 2024
