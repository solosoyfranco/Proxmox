#!/bin/bash
#
#Note: Change -> "0000\:0X\:00.0" for your GPU PCI ID
# ***just change the "X" for your GPU Serial***
# you can find this serial number by running the following command 
# lspci -k
#
echo 1 > /sys/bus/pci/devices/0000\:0X\:00.0/remove
echo 1 > /sys/bus/pci/rescan

## Save and quit
## 
