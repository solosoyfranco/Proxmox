## Step 1: Enable IOMMU (Input Output Memory Management Unit)

By activating this function, a virtual machine created on our Proxmox hypervisor will be able to directly access a PCI peripheral of our host (for example a PCI Express graphics card)

You must activate this function in the bios of the motherboard of your Proxmox host.

*Check the folder called BIOS inside of 01_install, where I show the changes I made for my MOBO's*

---

## Step 2: activate the IOMMU in Proxmox (for my Gigabyte X570 Aourus Master)

Once connected in SSH (root) on your host, paste the following line:
```bash

bash <(curl -s https://raw.githubusercontent.com/solosoyfranco/Proxmox/main/03_Win10/AMD.sh) install

```
**NOTE**: dont run this script more than once.

---

### Locate and copy the SERIAL and ID of the numbers on your video card... I also included the digits that are on the NVIDIA audio card
Example:
`01:00.0 3D controller [0302]: NVIDIA Corporation Device **[10de:1f95]** (rev a1)`

### Paste your digits separated by commas 
Example:
` 10de:2204,10de:1aef `

### Note: Edit or change the VFIO ID  
```bash

nano /etc/modprobe.d/vfio.conf

```

## Step 3: Change your Serial in the fix_gpu_pass.sh file
This file is already on the crontab at every reboot, to avoid the GPU being used by proxmox
```bash

# instructions inside of the file
nano /root/fix_gpu_pass.sh

```

### reboot Proxmox
`reboot`

## Step 4: Check your system
Run the following commands to make sure all is good
```bash

# check IOMMU is active
dmesg | grep 'remapping'
# Output:
# [    2.267640] AMD-Vi: Interrupt remapping enabled

-----------------------------------------------------

# check IOMMU is being enable
dmesg | grep -e DMAR -e IOMMU
# Output:
# [    2.263307] pci 0000:00:00.2: AMD-Vi: IOMMU performance counters supported
# [    2.267636] pci 0000:00:00.2: AMD-Vi: Found IOMMU cap 0x40
# [    2.267991] perf/amd_iommu: Detected AMD IOMMU #0 (2 banks, 4 counters/bank).

-----------------------------------------------------

# check kernel drivers in use
lspci -k
# Output:
# Subsystem: eVga.com. Corp. GA102 [GeForce RTX 3090]
# Kernel driver in use: vfio-pci
# Kernel modules: nvidiafb, nouveau


```

## Step 5: Create Win10 VM
Prerequistes
* Have loaded a Win10 ISO on the Proxmox
* Do not have 'VM-ID 110' in use
* have at least 60gb of disk space for the virtual machine
  * I have found better performance when I dedicate a hard drive to be hosting windows, performing a direct HDD passthrough. 
* The following script will do the basic creation of a virtual machine ready to run Windows.
    After running the script you will just have to do the following from the GUI
    * Connect a hard drive for the OS (virtual or passthrough) depending on your preference.
    * Add your Windows 10 ISO into the drive
    * Add the video card to passthrough
    * Add peripherals (Keyboard, Mouse, extra HDD, etc)
    * Edit RAM
    * Edit Cores
  