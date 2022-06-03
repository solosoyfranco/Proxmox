#!/bin/bash

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
#update initram
update-initramfs -u -k all
#update grub
update-grub
#add the script "fix_gpu_pass" to the crontab
crontab -l 2>/dev/null; echo "@reboot /root/fix_gpu_pass.sh" | crontab
echo "----------------------------------------------------------------"
lspci -nn -k | grep -EA3 'VGA|3D|Display|Audio'
echo "----------------------------------------------------------------"
echo "now copy the video card serial and paste it in the fix_gpu_pass file"
echo "nano /root/fix_gpu_pass.sh"
echo "please REBOOT your system after you save the file"
echo "----------------------------------------------------------------"