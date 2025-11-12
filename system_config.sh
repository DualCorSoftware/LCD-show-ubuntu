#!/bin/bash

version=`lsb_release -r | awk -F ' '  '{printf $NF}'`

if [ $(getconf WORD_BIT) = '32' ] && [ $(getconf LONG_BIT) = '64' ] ; then
hardware_arch=64
else
hardware_arch=32
fi

# Ubuntu version detection and configuration selection
if [[ "$version" < "20.04" ]]; then
if [ $hardware_arch -eq 32 ]; then
sudo cp -rf ./boot/config-nomal.txt ./boot/config.txt.bak
elif [ $hardware_arch -eq 64 ]; then
sudo cp -rf ./boot/config-nomal-64.txt ./boot/config.txt.bak
fi
elif [[ "$version" = "20.04" ]]; then
if [ $hardware_arch -eq 32 ]; then
sudo cp -rf ./boot/config-nomal-20.04.txt ./boot/config.txt.bak
elif [ $hardware_arch -eq 64 ]; then
sudo cp -rf ./boot/config-nomal-20.04-64.txt ./boot/config.txt.bak
fi
elif [[ "$version" = "20.10" ]]; then
if [ $hardware_arch -eq 32 ]; then
sudo cp -rf ./boot/config-nomal-20.10-32.txt ./boot/config.txt.bak
elif [ $hardware_arch -eq 64 ]; then
# Fallback to 32-bit config if 64-bit version doesn't exist
if [ -f ./boot/config-nomal-20.10-64.txt ]; then
sudo cp -rf ./boot/config-nomal-20.10-64.txt ./boot/config.txt.bak
else
sudo cp -rf ./boot/config-nomal-20.10-32.txt ./boot/config.txt.bak
fi
fi
elif [[ "$version" > "20.10" ]] && [[ "$version" < "22.04" ]]; then
if [ $hardware_arch -eq 32 ]; then
sudo cp -rf ./boot/config-nomal-20.10-32.txt ./boot/config.txt.bak
elif [ $hardware_arch -eq 64 ]; then
# Fallback to 32-bit config if 64-bit version doesn't exist
if [ -f ./boot/config-nomal-20.10-64.txt ]; then
sudo cp -rf ./boot/config-nomal-20.10-64.txt ./boot/config.txt.bak
else
sudo cp -rf ./boot/config-nomal-20.10-32.txt ./boot/config.txt.bak
fi
fi
elif [[ "$version" = "22.04" ]]; then
if [ $hardware_arch -eq 32 ]; then
sudo cp -rf ./boot/config-nomal-22.04-32.txt ./boot/config.txt.bak
elif [ $hardware_arch -eq 64 ]; then
sudo cp -rf ./boot/config-nomal-22.04-64.txt ./boot/config.txt.bak
fi
elif [[ "$version" = "24.04" ]] || [[ "$version" = "24.10" ]]; then
# Ubuntu 24.04 LTS and 24.10 use same boot configuration as 22.04
if [ $hardware_arch -eq 32 ]; then
# 32-bit support is unlikely on Ubuntu 24.04+, but include for completeness
if [ -f ./boot/config-nomal-24.04-32.txt ]; then
sudo cp -rf ./boot/config-nomal-24.04-32.txt ./boot/config.txt.bak
else
sudo cp -rf ./boot/config-nomal-22.04-32.txt ./boot/config.txt.bak
fi
elif [ $hardware_arch -eq 64 ]; then
if [ -f ./boot/config-nomal-24.04-64.txt ]; then
sudo cp -rf ./boot/config-nomal-24.04-64.txt ./boot/config.txt.bak
else
sudo cp -rf ./boot/config-nomal-22.04-64.txt ./boot/config.txt.bak
fi
fi
elif [[ "$version" > "24.10" ]]; then
# Future Ubuntu versions - use latest available config
if [ $hardware_arch -eq 32 ]; then
if [ -f ./boot/config-nomal-24.04-32.txt ]; then
sudo cp -rf ./boot/config-nomal-24.04-32.txt ./boot/config.txt.bak
else
sudo cp -rf ./boot/config-nomal-22.04-32.txt ./boot/config.txt.bak
fi
elif [ $hardware_arch -eq 64 ]; then
if [ -f ./boot/config-nomal-24.04-64.txt ]; then
sudo cp -rf ./boot/config-nomal-24.04-64.txt ./boot/config.txt.bak
else
sudo cp -rf ./boot/config-nomal-22.04-64.txt ./boot/config.txt.bak
fi
fi
elif [[ "$version" > "22.04" ]]; then
# Catch any other versions between 22.04 and 24.04 (like 23.04, 23.10)
if [ $hardware_arch -eq 32 ]; then
sudo cp -rf ./boot/config-nomal-22.04-32.txt ./boot/config.txt.bak
elif [ $hardware_arch -eq 64 ]; then
sudo cp -rf ./boot/config-nomal-22.04-64.txt ./boot/config.txt.bak
fi
fi
