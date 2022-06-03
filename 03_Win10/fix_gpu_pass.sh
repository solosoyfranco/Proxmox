#!/bin/bash
#//Note Change "0000\:0X\:00.0" for your GPU PCI ID
echo 1 > /sys/bus/pci/devices/0000\:0c\:00.0/remove
echo 1 > /sys/bus/pci/rescan
