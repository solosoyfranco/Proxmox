## Step 1: Enable IOMMU (Input Output Memory Management Unit)

By activating this function, a virtual machine created on our Proxmox hypervisor will be able to directly access a PCI peripheral of our host (for example a PCI Express graphics card)

You must activate this function in the bios of the motherboard of your Proxmox host.

*Check the folder called BIOS inside of 01_install, where I show the changes I made for my MOBO's*

---

## Step 2: activate the IOMMU in Proxmox 
* AMD ONLY (tested on a Gigabyte X570 Aourus Master) 
Once connected in SSH (root) on your host, paste the following line:
```bash

bash <(curl -s https://raw.githubusercontent.com/solosoyfranco/Proxmox/main/03_Win10/AMD.sh) install

```
**NOTE**: dont run this script more than once.

* INTEL ONLY (tested on a Z170MX Gaming 5) 
Once connected in SSH (root) on your host, paste the following line:
```bash

bash <(curl -s https://raw.githubusercontent.com/solosoyfranco/Proxmox/main/03_Win10/INTEL.sh) install

```
**NOTE**: dont run this script more than once.

---
---
**The following steps are included in the script, but you can do it manually**
---
### Locate and copy the ID of the numbers on your video card... I also included the digits that are on my GPU audio card
```bash
lspci -nn
```
Example output:
`01:00.0 3D controller [0302]: NVIDIA Corporation Device **[10de:1f95]** (rev a1)`

### Paste your digits separated by commas 
Example:
` 10de:2204,10de:1aef `

### Note: Edit or change the VFIO ID  
```bash

nano /etc/modprobe.d/vfio.conf

```

### Locate and change your GPU Serial in the fix_gpu_pass.sh file
```bash
lspci -k
```
Example output:
`0c:00.0 VGA compatible controller: NVIDIA Corporation GA102 [GeForce RTX 3090] (rev a1)`

This file is already on the crontab at every reboot, to avoid the GPU being used by proxmox
```bash

# instructions inside of the file
nano /root/fix_gpu_pass.sh

```
---
---
### reboot Proxmox
`reboot`

## Step 3: Check your system
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

## Step 4: Create Win10 VM
Prerequistes
* Have loaded a Win10 ISO on the Proxmox
* Do not have 'VM-ID 110' in use
* have at least 60gb of disk space for the virtual machine
  * I have found better performance when I dedicate a hard drive to be hosting windows, performing a direct HDD passthrough. 
---

* The following script will do the basic creation of a virtual machine and download VirtIO drivers to run Windows.
```bash

bash <(curl -s https://raw.githubusercontent.com/solosoyfranco/Proxmox/main/03_Win10/Win10.sh) install


```

    After running the script you will just have to do the following from the GUI
  
    * Edit Memory RAM
    * Edit Processor Cores qty
    * Display -> None
    * Add your Windows ISO -> ide0
    * Add VirtIO drivers ISO -> ide1
    * Add Network Device -> Model: Virtio (paravirtualized)
    * Add Audio Device (in case you want to use the MB Audio output)
      * Audio Device: ich9-intel-hda
      * Dirver: SPICE
        * SSH to proxmox (Note: For some reason didnt work adding from GUI)
          * lspci -nn -k
          * Find your Audio device:
            * `0f:00.4 Audio device [0403]: Advanced Micro Devices, Inc. [AMD] Starship/Matisse HD Audio Controller [1022:1487]`
            * Eg: `qm set 110 -hostpci1 0f:00.4`

    * Add Efi Disk
      * Pre-enroll keys:[]
    * Add the video card to passthrough
      * Add PCI-Device (dont add the GPU audio device)
        * [x] All Functions
        * [x] Primary GPU
        * [x] PCI-Express
        * [x] ROM-BAR
    * Add Keyboard and mouse
      * Add USB-Device
        * [x] Use USB Vendor/Device ID
    * Connect a hard drive for the OS (virtual or passthrough) depending on your preference.
      * Add Harddrive
        * Bus/device: SCSI
        * Cache: write back
        * Discard: [x]
        * SSD Emulation: [x]
        * format: 
          * RAW has a little better performance
          * QCOW2 has snapshots
      * Passthrough is the best performance
        * go to Node->Disks
          * check the name of the drive
          * Wipe disk
          * Initialize disk with GPT
        * SSH client to the node
          * find your disk with the command: ls -l /dev/disk/by-id/
          * example: qm set 110 -scsi1 /dev/disk/by-id/yourDiskNameHere
        * Options tab:
          * Use tablet for pointer: NO
  ### Run Win10 VM
    * Proceed the Win10 installation
      * Select the driver to install
        * Browse
          * CD Drive -> Virtio-win-01.1.215
          * amd64 -> w10
          * Next (scanning)
          * Select Drive 0 Unallocated Space
          * and proceed with a normal installation
          * once in Windows, go to cd drive (virtio)
            * install **virtio-win-gt-x64.msi**
  
### Windows Recomendations
* Nvidia clean installer [NVCleanInstall](https://www.techpowerup.com/download/techpowerup-nvcleanstall/) 
* Automatically login [Link](https://www.cnet.com/tech/services-and-software/automatically-log-in-to-your-windows-10-pc/)
  * Fix with registry [Link](https://www.askvg.com/fix-users-must-enter-a-user-name-and-password-to-use-this-computer-checkbox-missing-in-windows-10/)
* Enable RDP in settings
* Barrier for Win [Link](https://github.com/debauchee/barrier/releases)
* Install [Chocolatey](https://chocolatey.org/install)
  * My must-have software script 
    ```bash
      choco install firefox -y
      choco install 7zip.install -y
      choco install vlc -y
      choco install winrar -y
      choco install putty.install -y
      choco install vscode -y
      choco install filezilla -y
      choco install k-litecodecpackfull -y
      # choco install microsoft-windows-terminal #broken
      # choco install advanced-ip-scanner #broken
      choco install brave -y
      choco install everything -y
      choco install qbittorrent -y
      choco install discord.install -y
      choco install handbrake.install -y
      choco install prusaslicer -y
      # choco install autodesk-fusion360 ##broken
      choco install eartrumpet -y
      choco install parsec -y
      choco install steam-client -y
      choco install epicgameslauncher -y
      choco install moonlight-qt.install -y
      choco install lghub -y
      choco install spotify -y

    ``` 