#!/bin/bash
#
# Kernel Module Availability Checker for LCD-show-ubuntu
# This script checks if the necessary kernel modules for TFT LCD displays
# are available on the system.
#

echo "========================================"
echo "LCD Driver Kernel Module Checker"
echo "========================================"
echo ""

# Get system information
KERNEL_VERSION=$(uname -r)
UBUNTU_VERSION=$(lsb_release -r | awk -F ' ' '{printf $NF}')
ARCH=$(uname -m)

echo "System Information:"
echo "  Ubuntu Version: $UBUNTU_VERSION"
echo "  Kernel Version: $KERNEL_VERSION"
echo "  Architecture:   $ARCH"
echo ""

# Check for required modules
MODULES_TO_CHECK=(
    "fbtft"
    "fbtft_device"
    "fb_ili9486"
    "ads7846"
    "spi_bcm2835"
    "spidev"
)

echo "Checking for required kernel modules:"
echo "--------------------------------------"

MISSING_MODULES=()
AVAILABLE_MODULES=()

for module in "${MODULES_TO_CHECK[@]}"; do
    # Check if module exists in /lib/modules
    if modinfo "$module" &> /dev/null; then
        echo "  ✓ $module - Available"
        AVAILABLE_MODULES+=("$module")
    else
        echo "  ✗ $module - NOT FOUND"
        MISSING_MODULES+=("$module")
    fi
done

echo ""

# Check if modules are built-in (not as loadable modules)
echo "Checking for built-in drivers:"
echo "--------------------------------------"

BUILTIN_FOUND=false

if [ -f /boot/config-$KERNEL_VERSION ]; then
    echo "Kernel configuration found at /boot/config-$KERNEL_VERSION"

    # Check for fbtft and related configs
    if grep -q "CONFIG_FB_TFT=y" /boot/config-$KERNEL_VERSION 2>/dev/null; then
        echo "  ✓ FB_TFT is built into kernel"
        BUILTIN_FOUND=true
    elif grep -q "CONFIG_FB_TFT=m" /boot/config-$KERNEL_VERSION 2>/dev/null; then
        echo "  ✓ FB_TFT is available as module"
        BUILTIN_FOUND=true
    else
        echo "  ✗ FB_TFT is not enabled in kernel configuration"
    fi

    if grep -q "CONFIG_TOUCHSCREEN_ADS7846=y" /boot/config-$KERNEL_VERSION 2>/dev/null; then
        echo "  ✓ ADS7846 touchscreen is built into kernel"
        BUILTIN_FOUND=true
    elif grep -q "CONFIG_TOUCHSCREEN_ADS7846=m" /boot/config-$KERNEL_VERSION 2>/dev/null; then
        echo "  ✓ ADS7846 touchscreen is available as module"
        BUILTIN_FOUND=true
    else
        echo "  ✗ ADS7846 touchscreen is not enabled in kernel configuration"
    fi
else
    echo "Kernel configuration file not found at /boot/config-$KERNEL_VERSION"
fi

echo ""

# Check if device tree overlay directory exists
echo "Checking boot configuration:"
echo "--------------------------------------"

if [ -d /boot/firmware/overlays ]; then
    echo "  ✓ Device tree overlay directory exists: /boot/firmware/overlays"
else
    echo "  ✗ Device tree overlay directory NOT FOUND: /boot/firmware/overlays"
    echo "    This directory is required for Raspberry Pi device tree overlays"
fi

if [ -f /boot/firmware/config.txt ]; then
    echo "  ✓ Boot configuration file exists: /boot/firmware/config.txt"
else
    echo "  ✗ Boot configuration file NOT FOUND: /boot/firmware/config.txt"
fi

echo ""

# Provide recommendations
echo "========================================"
echo "Recommendations:"
echo "========================================"

if [ ${#MISSING_MODULES[@]} -eq 0 ] || [ "$BUILTIN_FOUND" = true ]; then
    echo "✓ All required kernel modules appear to be available."
    echo "  You should be able to proceed with the LCD driver installation."
else
    echo "⚠ WARNING: Some kernel modules are missing!"
    echo ""
    echo "The following modules are required but not found:"
    for module in "${MISSING_MODULES[@]}"; do
        echo "  - $module"
    done
    echo ""
    echo "Possible solutions:"
    echo ""
    echo "1. Install linux-modules-extra package:"
    echo "   sudo apt-get update"
    echo "   sudo apt-get install linux-modules-extra-raspi"
    echo ""
    echo "2. For Ubuntu 24.04+, you may need the linux-raspi kernel:"
    echo "   sudo apt-get install linux-raspi"
    echo ""
    echo "3. Install generic raspberry pi kernel:"
    echo "   sudo apt-get install linux-image-raspi"
    echo ""
    echo "4. Check if you're using the Raspberry Pi kernel:"
    echo "   If using a generic Ubuntu kernel instead of the Pi-specific"
    echo "   kernel, the fbtft drivers may not be available."
    echo ""
    echo "5. For custom kernels, you may need to compile the modules:"
    echo "   - Enable CONFIG_FB_TFT in kernel configuration"
    echo "   - Enable CONFIG_TOUCHSCREEN_ADS7846"
    echo "   - Recompile and install the kernel"
fi

echo ""

# Check for SPI interface
echo "Checking SPI interface:"
echo "--------------------------------------"

if [ -d /dev/spidev* ] || ls /dev/spidev* &> /dev/null; then
    echo "  ✓ SPI device found: $(ls /dev/spidev* 2>/dev/null | head -1)"
else
    echo "  ℹ SPI device not found (this is normal before configuration)"
    echo "    SPI will be enabled during LCD driver installation"
fi

echo ""
echo "========================================"
echo "Check complete!"
echo "========================================"
