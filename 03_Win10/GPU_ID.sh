#!/bin/bash
# VARIABLES
timestamp=$(date +%s)

echo "----------------------------------------------------------------"
echo "Start of script"
echo "----------------------------------------------------------------"

#Ask the user for their values
echo "Please paste the GPU ID separated by comma"
echo "example: 10de:2204,10de:1aef "
read gpu_id
echo "options vfio-pci ids=$gpu_id disable_vga=1" > /etc/modprobe.d/vfio.conf
echo "Done"
echo "you can edit your VFIO ID with the following command:"
echo "nano /etc/modprobe.d/vfio.conf"

### update changes
echo " - update initram"
update-initramfs -u -k all
echo " - update grub"
update-grub



echo "----------------------------------------------------------------"
echo "end of script please REBOOT NOW"
echo "----------------------------------------------------------------"