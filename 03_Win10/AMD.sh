#!/bin/bash
# VARIABLES
timestamp=$(date +%s)

echo "----------------------------------------------------------------"
echo "Start of script"
echo "----------------------------------------------------------------"

#1 backup grub and mod the file
echo "- save original grub"
mv /etc/default/grub /etc/default/grub-$timestamp.bak
#change time of bootscreen and deactivate GPU to initialize with proxmox
echo "- creating a mod grub"
echo 'GRUB_DEFAULT=0' >> /etc/default/grub
echo 'GRUB_TIMEOUT=1' >> /etc/default/grub
echo 'GRUB_DISTRIBUTOR=`lsb_release -i -s 2> /dev/null || echo Debian`' >> /etc/default/grub
echo 'GRUB_CMDLINE_LINUX_DEFAULT="quiet amd_iommu=on textonly nomodeset video=vesafb:off video=astdrmfb video=efifb:off"' >> /etc/default/grub
echo 'GRUB_CMDLINE_LINUX=""' >> /etc/default/grub


#add extra options
echo "- allow unsafe interrupts"
echo "options vfio_iommu_type1 allow_unsafe_interrupts=1" > /etc/modprobe.d/iommu_unsafe_interrupts.conf
echo "- kvm ignore msrs"
echo "options kvm ignore_msrs=1" > /etc/modprobe.d/kvm.conf
#VFIO drivers
echo "- Add VFIO into modules file"
echo "vfio
vfio_iommu_type1
vfio_pci
vfio_virqfd" >> /etc/modules
#blacklist drivers
echo "- blacklist drivers for proxmox"
echo "blacklist nvidia
blacklist nouveau
blacklist radeon
blacklist nvidiafb" >> /etc/modprobe.d/blacklist.conf

echo "----------------------------------------------------------------"
echo "Copy your GPU IDs below and run the next script"
echo "----------------------------------------------------------------"
lspci -nn -k | grep -EA3 'VGA|3D|Display|Audio'

curl -s https://raw.githubusercontent.com/solosoyfranco/Proxmox/main/03_Win10/fix_gpu_pass.sh -o "fix_gpu_pass.sh"
curl -s https://raw.githubusercontent.com/solosoyfranco/Proxmox/main/03_Win10/GPU_ID.sh -o "gpu_id.sh"
chmod +x /root/*.sh
