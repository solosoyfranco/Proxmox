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


Optional

* Dark mode
* Remove LVM Partition

```bash

wget -q -O - https://raw.githubusercontent.com/solosoyfranco/Proxmox/main/01_Install/optional.sh

```