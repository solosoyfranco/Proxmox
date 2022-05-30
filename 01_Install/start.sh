#!/bin/bash


# USAGE

# SOURCES
# https://pve.proxmox.com/wiki/Package_Repositories#sysadmin_no_subscription_repo
# https://github.com/Tontonjo/proxmox/

# VARIABLES
distribution=$(grep -F "VERSION_CODENAME=" /etc/os-release | cut -d= -f2)
timestamp=$(date +%s)

echo "----------------------------------------------------------------"
echo "Start of script"
echo "----------------------------------------------------------------"

#1 Removing / Adding repositories
# pve-enterprise.list
echo "- save original pve-enterprise.list"
cp /etc/apt/sources.list.d/pve-enterprise.list /etc/apt/sources.list.d/pve-enterprise-$timestamp.bak

echo "- verify pve-entreprise.list"
if grep -Fxq "# deb https://enterprise.proxmox.com/debian/pve $distribution pve-enterprise" /etc/apt/sources.list.d/pve-enterprise.list
  then
    echo "- Repo already commented"
  else
    echo "- Hiding the repository by adding # to the first line"
    sed -i 's/^/#/' /etc/apt/sources.list.d/pve-enterprise.list
fi

# pve-no-subscription
echo "- Backup sources.list"
cp /etc/apt/sources.list /etc/apt/sources-$timestamp.bak

echo "- Checking sources.list"
if grep -Fxq "deb http://download.proxmox.com/debian/pve $distribution pve-no-subscription" /etc/apt/sources.list
  then
    echo "- Repo already commented"
  else
    echo "- Added pve-no-subscription repo"
    echo "deb http://download.proxmox.com/debian/pve $distribution pve-no-subscription" >> /etc/apt/sources.list
fi

#3: Update
echo "- Update OS"
pveam update
apt update -y
apt full-upgrade -y



#4: Remove the subscription pop-up
echo "- Backup proxmoxlib.js"
cp /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib-$timestamp.bak

echo "- Verify pop-up souscription"
if [ $(grep -c "void({ //Ext.Msg.show({" /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js) -gt 0 ]
  then
    echo "- Modification alredy present"
  else
    echo "- Application modification"
    sed -Ezi.bak "s/(Ext.Msg.show\(\{\s+title: gettext\('No valid subscription')/void\(\{ \/\/\1/g" /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js
    systemctl restart pveproxy.service
fi

#4: Optimitation of SWAP memory
echo "- Paramatrage du SWAP pour qu'il ne s'active que lorsqu'il ne reste plus que 10% de RAM dispo"
sysctl vm.swappiness=10
echo "- Désactivation du SWAP"
swapoff -a
echo "- Activation du SWAP"
swapon -a

echo "----------------------------------------------------------------"
echo "End of script"
echo "----------------------------------------------------------------"