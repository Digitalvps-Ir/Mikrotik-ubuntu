#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[38;5;68m'
GREEN_ALT='\033[38;5;35m'
YELLOW='\033[1;33m'
NC='\033[0m'
clear
echo -e "${BLUE}-------------------------------------------"
echo "   Welcome to the MikroTik Installation    "
echo "           Powered by Digitalvps.ir           "
echo -e "-------------------------------------------${NC}"
sleep 5
echo -e "${YELLOW}Please select the MikroTik version to install:${NC}"
echo "1) 7.14.3"
echo "2) 7.9"
echo "3) 7.7"
echo "4) 6.49.15"
echo "5) 6.49.13"
read -p "Enter the number corresponding to your choice: " version_choice
case $version_choice in
    1) version="7.14.3";;
    2) version="7.9";;
    3) version="7.7";;
    4) version="6.49.15";;
    5) version="6.49.13";;
    *) echo -e "${RED}Invalid choice. Exiting.${NC}"; exit 1;;
esac
echo -e "${GREEN_ALT}You have selected version ${version}.${NC}"
echo -e "${YELLOW}Step 1: Installing required packages...${NC}"
sudo apt-get update
sudo apt-get install -y kpartx
if [ $? -ne 0 ]; then
    echo -e "${RED}Failed to install required packages. Exiting.${NC}"
    exit 1
fi
echo -e "${GREEN_ALT}Required packages installed.${NC}"
echo -e "${YELLOW}Step 2: Downloading MikroTik installation file...${NC}"
wget https://data.digitalvps.ir/scripts/MikroTik/chr-${version}.img.zip -O chr.img.zip > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo -e "${RED}Failed to download MikroTik installation file. Exiting.${NC}"
    exit 1
fi
echo -e "${GREEN_ALT}MikroTik installation file downloaded.${NC}"
echo -e "${YELLOW}Step 3: Extracting MikroTik installation file...${NC}"
gunzip -c chr.img.zip > chr.img
if [ $? -ne 0 ]; then
    echo -e "${RED}Failed to extract MikroTik installation file. Exiting.${NC}"
    exit 1
fi
echo -e "${GREEN_ALT}MikroTik installation file extracted.${NC}"
echo -e "${YELLOW}Step 4: Setting up loop device and partitions...${NC}"
LOOP_DEVICE=$(sudo losetup -f --show chr.img)
if [ $? -ne 0 ]; then
    echo -e "${RED}Failed to set up loop device. Exiting.${NC}"
    exit 1
fi
sudo kpartx -a $LOOP_DEVICE > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo -e "${RED}Failed to set up partitions. Exiting.${NC}"
    exit 1
fi
echo -e "${GREEN_ALT}Loop device set up at ${LOOP_DEVICE}.${NC}"
echo -e "${YELLOW}Step 5: Mounting MikroTik installation image...${NC}"
sudo mount /dev/mapper/$(basename ${LOOP_DEVICE})p1 /mnt > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo -e "${RED}Failed to mount installation image. Exiting.${NC}"
    exit 1
fi
echo -e "${GREEN_ALT}Installation image mounted.${NC}"
echo -e "${YELLOW}Step 6: Configuring network settings...${NC}"
INTERFACE=$(ip route | grep default | awk '{print $5}')
ADDRESS=$(ip addr show $INTERFACE | grep global | cut -d' ' -f 6 | head -n 1)
GATEWAY=$(ip route list | grep default | cut -d' ' -f 3)
if [ -z "$ADDRESS" ] || [ -z "$GATEWAY" ]; then
    echo -e "${RED}Failed to configure network settings. Exiting.${NC}"
    exit 1
fi
echo -e "${GREEN_ALT}Network settings configured. IP Address: $ADDRESS, Gateway: $GATEWAY${NC}"
echo -e "${YELLOW}Step 7: Identifying storage device...${NC}"
DISK_DEVICE=$(fdisk -l | grep "^Disk /dev" | grep -v "^Disk /dev/loop" | cut -d' ' -f2 | tr -d ':')
if [ -z "$DISK_DEVICE" ]; then
    echo -e "${RED}No suitable storage device found. Exiting.${NC}"
    exit 1
fi
echo -e "${GREEN_ALT}Using storage device: $DISK_DEVICE${NC}"
echo -e "${YELLOW}Step 8: Syncing disk...${NC}"
echo u | sudo tee /proc/sysrq-trigger > /dev/null 2>&1
sudo dd if=chr.img bs=1024 of=$DISK_DEVICE
if [ $? -ne 0 ]; then
    echo -e "${RED}Failed to prepare disk for installation. Exiting.${NC}"
    exit 1
fi
sudo sync
echo -e "${GREEN_ALT}Disk sync completed.${NC}"
echo -e " "
echo -e "${YELLOW}--------------------------------------------------"
echo -e "   ${GREEN_ALT}Visit ${RED}Digitalvps.ir ${GREEN_ALT}for Powerful VPS in:  "
echo -e "         ${BLUE}Iran, Netherlands, Germany${NC}  "
echo -e "             ${GREEN_ALT}Locations!${NC}"
echo -e "     ${GREEN_ALT}Thank you for choosing ${RED}Digitalvps!${NC}"
echo -e "${YELLOW}--------------------------------------------------${NC}"
sleep 5
echo -e "${GREEN_ALT}-------------------------------------------"
echo -e "${GREEN_ALT}  Installation completed successfully!     ${NC}"
echo -e "${GREEN_ALT}  Your MikroTik installation is ready.     ${NC}"
echo -e "${GREEN_ALT}-------------------------------------------${NC}"
rm -f chr.img.zip > /dev/null 2>&1
sudo umount /mnt > /dev/null 2>&1
sudo kpartx -d $LOOP_DEVICE
sudo losetup -d $LOOP_DEVICE
echo -e "${YELLOW}Booting...${NC}"
echo -e "${GREEN_ALT}If Mikrotik not booted, Power Off/On VPS from Panel.${NC}"
echo b | sudo tee /proc/sysrq-trigger > /dev/null 2>&1
