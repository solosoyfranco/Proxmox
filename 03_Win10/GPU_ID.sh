#!/bin/bash

#variables

echo "----------------------------------------------------------------"
echo "Start of script"
echo "----------------------------------------------------------------"
echo " Copy and paste the GPU IDs"
#Ask the user for their values
echo "----------------------------------------------------------------"
#show the PC IDS
lspci -nn -k | grep -EA3 'VGA|3D|Display|Audio'
echo "----------------------------------------------------------------"
read -p "Please paste the GPU ID separated by comma: " gpu_id
echo "options vfio-pci ids=$gpu_id disable_vga=1" > /etc/modprobe.d/vfio.conf
echo "----------------------------------------------------------------"
echo "you can check or edit your VFIO ID with the following command:"
echo "nano /etc/modprobe.d/vfio.conf"
echo "----------------------------------------------------------------"
echo "----------------------------------------------------------------"
echo "update-initramfs -u -k all"
echo "update-grub"
echo "end of script please REBOOT NOW"
echo "----------------------------------------------------------------"