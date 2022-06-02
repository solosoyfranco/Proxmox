## Step 1: Enable IOMMU (Input Output Memory Management Unit)

By activating this function, a virtual machine created on our Proxmox hypervisor will be able to directly access a PCI peripheral of our host (for example a PCI Express graphics card)

You must activate this function in the bios of the motherboard of your Proxmox host.

*Check the folder called BIOS where I show the changes I made for my MOBO's*

---

## Step 2: activate the IOMMU in Proxmox (for my Gigabyte X570 Aourus Master)

Once connected in SSH (root) on your host, paste the following line:
```bash
wget -q -O - https://raw.githubusercontent.com/solosoyfranco/Proxmox/main/03_Win10/AMD.sh | bash

```
### Locate and take note of the numbers on your video card... I also included the digits that are on the NVIDIA audio card
Example:
`01:00.0 3D controller [0302]: NVIDIA Corporation Device **[10de:1f95]** (rev a1)`

### Paste your digits separated by commas in the following command and execute it
Example:
`echo "options vfio-pci ids=10de:2204,10de:1aef disable_vga=1" > /etc/modprobe.d/vfio.conf`
```bash
echo "options vfio-pci ids=(GPU number,Audio number) disable_vga=1" > /etc/modprobe.d/vfio.conf
```

### update changes
update-initramfs -u -k all
update-grub

## reboot Proxmox
reboot



* dmesg | grep 'remapping'
`[    2.267640] AMD-Vi: Interrupt remapping enabled`




## Step 3: Create Win10 VM
Prerequisites

1- Have loaded a Win10 ISO on a volume of its proxmox host
Important parameters:
Remember to enable advanced settings
OS tab

1- Indicate the ISO image of Win10

2- Type of OS = Microsoft Windows

3- Release = 10/2016/2019
System tab

1- Graphics card = Default

2- QEMU agent = true

3- Bios = ovmf (uefi)

4- Enter a volume for the UEFI partition

5- Machine = q35 --> to allow PCI Express management
hard drive tab

1- Bus = SCSI

2- Size = At ​​your convenience

3- Cache = Write back

4- Discard = true --> if your volume is on an SSD

5- SSD emulation --> if your volume is on an SSD
CPU tab

1- Number of hearts: 4 (or +)
Memory tab

1- Memory: 4096 MB (or +)

2- Uncheck ballooning device
Network tab

1- Bridge = vmbr0

2- Model = Intel E1000
Installing Win10

See video
Installing Windows VirtIO Drivers

From the VM, download the latest version available

https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/latest-virtio/virtio-win.iso

Open the ISO and run the following programs

virtio-win-gt-x64.msi
virtio-win-guest-tools

Enabling remote desktop

From the VM, in Settings > System > Remote Desktop, activate the remote desktop and note the name of the PC
Step 6: Customize the Win10 VM

In the hardware tab, we modify the network card model by VirtIO

We also take the opportunity to remove the Windows ISO

Finally, we connect in SSH to our Proxmox host to edit the configuration of the VM

# Edition de la configuration de la VM (101 dans mon cas)
nano /etc/pve/qemu-server/101.conf

# contenu du fichier 'origine'
balloon: 2048
bios: ovmf
boot: order=sata0;ide2;net0
cores: 4
efidisk0: vms:100/vm-100-disk-1.qcow2,size=128K
hostpci0: 01:00,pcie=1,x-vga=on
ide2: vms:iso/Win10_1909_French_x64.iso,media=cdrom
machine: pc-q35-5.2
memory: 4096
name: pve-win10
net0: e1000=BA:FE:8D:B8:04:16,bridge=vmbr0,firewall=1
numa: 0
ostype: win10
sata0: vms:100/vm-100-disk-0.qcow2,cache=writeback,size=32G
scsihw: virtio-scsi-pci
smbios1: uuid=8199783e-a724-465b-9783-c4b9944f203b
sockets: 1
vmgenid: 34ce9633-cbc9-4858-8472-794e10deb63f

# Ajouter les deux lignes suivantes après le nombre de cores
echo "cpu: host,hidden=1,flags=+pcid" >> /etc/pve/qemu-server/101.conf
echo "hostpci0: XX:XX,pcie=1,x-vga=on" >> /etc/pve/qemu-server/101.conf #Remplacer XX:XX par les PCI IDs de la carte graphique (lspci -v)
# Dans mon cas 
# echo "hostpci0: 01:00,pcie=1,x-vga=on" >> /etc/pve/qemu-server/101.conf

Step 7: Installing Parsec
Connect to remote desktop
Enable autologon in Win10

Open regedit

Find the following registry entry

HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\PasswordLess\Device

Change the value of the DevicePasswordLessBuildVersion key to 0 (instead of 2)

Open netplwiz , select your user and disable the option requiring user/password for login
Install Parsec

From the VM, connect to https://parsec.app/ and download the version for Windows 64 bits

Install it and create an account if you don't have one

Once connected in Parsec, select Settings > Host and activate "Machine lever user"

Also install Parsec on the guest machine and check in Settings > Client that Overlay is Off

NB: for Parsec to work, you must also install a small HDMI dongle on your host that simulates a screen for your graphics card

Here is the model I bought for 10€ on Amazon

EZDIY-FAB HDMI Displayport Dummy Plug Display Emulator for Headless PCs, BTC/ETH Mining Rig, 4096x2160@60Hz, 1-Pack

https://www.amazon.fr/dp/B07BCCTWMX/ref=cm_sw_em_r_mt_dp_WH8X7DAWB7P6BZSWYJG2
