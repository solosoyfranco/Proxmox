#!/bin/bash

echo "----------------------------------------------------------------"
echo " Copy and paste the GPU IDs"
#Ask the user for their values
echo "----------------------------------------------------------------"
#show the PC IDS
lspci -nn -k | grep -EA3 'VGA|3D|Display|Audio'
echo "----------------------------------------------------------------"
echo "Example: 10de:0a65, 10de:0be3, 10de:2204, 10de:1aef "
read -p "Please paste the GPU ID separated by comma: " gpu_id
echo "options vfio-pci ids=$gpu_id disable_vga=1" > /etc/modprobe.d/vfio.conf
echo "----------------------------------------------------------------"
echo "you can check or edit your VFIO ID with the following command:"
echo "nano /etc/modprobe.d/vfio.conf"
echo "----------------------------------------------------------------"
#update initram
update-initramfs -u -k all
#update grub
update-grub
#add the script "fix_gpu_pass" to the crontab
crontab -l 2>/dev/null; echo "@reboot /root/fix_gpu_pass.sh" | crontab
echo "----------------------------------------------------------------"
lspci -k
echo "----------------------------------------------------------------"
echo "now copy the video card serial and paste it in the fix_gpu_pass.sh file"
echo "nano /root/fix_gpu_pass.sh"
echo "Once you edit the fix_gpu_pass,REBOOT your system."
echo "NOTE: dont run this script more than once."
echo "----------------------------------------------------------------"