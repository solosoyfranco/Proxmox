#!/bin/bash
# VARIABLES
timestamp=$(date +%s)

echo "----------------------------------------------------------------"
echo "Start of script"
echo "----------------------------------------------------------------"

#1 backup grub and mod the file
echo "- save original grub"
cp /etc/default/grub /etc/default/grub-$timestamp.bak
#change time of bootscreen and deactivate GPU to initialize with proxmox
sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=1/g' /etc/default/grub
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="quiet"/GRUB_CMDLINE_LINUX_DEFAULT="quiet amd_iommu=on textonly nomodeset video=vesafb:off video=astdrmfb video=efifb:off"/g' /etc/default/grub

#extra options
echo "options vfio_iommu_type1 allow_unsafe_interrupts=1" > /etc/modprobe.d/iommu_unsafe_interrupts.conf
echo "options kvm ignore_msrs=1" > /etc/modprobe.d/kvm.conf
#VFIO drivers
echo "vfio" >> /etc/modules
echo "vfio_iommu_type1" >> /etc/modules
echo "vfio_pci" >> /etc/modules
echo "vfio_virqfd" >> /etc/modules
#blacklist drivers
echo "blacklist nvidia" >> /etc/modprobe.d/blacklist.conf
echo "blacklist nouveau" >> /etc/modprobe.d/blacklist.conf
echo "blacklist radeon" >> /etc/modprobe.d/blacklist.conf

#Example: this only apply to my system
#echo "options vfio-pci ids=10de:2204,10de:1aef disable_vga=1" > /etc/modprobe.d/vfio.conf



echo "----------------------------------------------------------------"
echo "take note of your GPU VFIO-PCI IDs and run the next script"
echo "----------------------------------------------------------------"
lspci -nn -k | grep -EA3 'VGA|3D|Display|Audio'