#!/bin/bash

# Download Virtio Drivers
cd /var/lib/vz/template/iso
wget -O virtio-win-0.1.215.iso https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/archive-virtio/virtio-win-0.1.215-1/virtio-win-0.1.215.iso

# install lhsw
apt install lshw -y


# make the VM
qm create 110 --boot order=ide0 --ide0 none,media=cdrom --ide1 none,media=cdrom --name Win10 --ostype win10 --agent 1 --memory 1024 --onboot no --cpu cputype=host,hidden=1 --machine q35 --cores 2 --sockets 1 --bios ovmf --scsihw virtio-scsi-pci --vmgenid 1



# copy and select the drive to passthrough
lshw -class disk -class storage
ls -l /dev/disk/by-id/
echo "----------------------------------------------"
echo "Example:"
echo "qm set 110 -scsi1 /dev/disk/by-id/yourDiskNameHere"
echo "----------------------------------------------"
