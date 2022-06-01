# Installing Proxmox Virtual Environment

* Installation from the official ISO
  * Link to [ISO PVE](https://www.proxmox.com/en/downloads/category/iso-images-pve)
* Ventoy software (Multiboot from USB Drive)
  * Link to [Ventoy](https://www.ventoy.net/en/download.html)
* I always try to install the operating system on a lower capacity SSD
* Proceed with the installation normally
  


### SSH to the server and run the following command


```bash

wget -q -O - https://raw.githubusercontent.com/solosoyfranco/Proxmox/main/01_Install/start.sh | bash

```
---
---
---

### *Optional*

* Dark mode
* Remove LVM Partition

```bash

wget -q -O - https://raw.githubusercontent.com/solosoyfranco/Proxmox/main/01_Install/optional.sh | bash

```
---
---
---
## Network Configuration - LACP
* This configuration may be different depending on the number of NICs your team has. In my experience and needs, I have found it quite useful to unify all the available cards into one to avoid bottlenecks by creating more "lanes", and connect all the VMs to a single interface.
* I do all of this from the GUI in each NODE:
  * PVE
    * System -> Network
    * remove but not apply changes yet = vmbr0 (Linux Bridge)
      * CREATE -> Linux Bond
        * Autostart: :heavy_check_mark:
        * Slaves: [all your Network Devices separated by SPACE]
        * Mode: LACP (802.3ad)
        * Hash Policy: layer2+3
      * CREATE -> Linux Bridge
        * IPv4/CIDR: 192.168.0.10/24
        * Gateway: 192.168.0.1/24
        * Autostart: :heavy_check_mark:
        * VLAN aware: :heavy_check_mark:
        * Bridge ports: bond0




## Cluster
* After having two or more installations ready, open the main node (GUI).
* I do all of this from the GUI in each NODE:
  * 
