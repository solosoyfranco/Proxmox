#!/bin/bash

# SOURCES
# https://dannyda.com/2020/05/10/how-to-delete-remove-local-lvm-from-proxmox-ve-pve-and-some-lvm-basics-commands/
# https://github.com/Weilbyte/PVEDiscordDark

#VARIABLES
timestamp=$(date +%s)

echo "----------------------------------------------------------------"
echo "Start of script"
echo "----------------------------------------------------------------"

echo "-unmount the lvm-Thin"
umount /dev/pve/data

echo "-remove partition"
echo yes | lvremove /dev/pve/data


echo "-resize the LVM and use the whole disk"
lvresize -l +100%FREE /dev/pve/root
resize2fs /dev/mapper/pve-root

echo "-backup storage.cfg"
cp /etc/pve/storage.cfg /etc/pve/storage-$timestamp.bak

echo "-edit storage.cfg"
sed -i 's/content iso,vztmpl,backup/content rootdir,backup,snippets,images,vztmpl,iso/g' /etc/pve/storage.cfg
sed -i '4,8d' /etc/pve/storage.cfg

echo "-Dark theme"
bash <(curl -s https://raw.githubusercontent.com/Weilbyte/PVEDiscordDark/master/PVEDiscordDark.sh ) install