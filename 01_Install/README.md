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

### *Optional*

* Dark mode
* Remove LVM Partition

```bash

wget -q -O - https://raw.githubusercontent.com/solosoyfranco/Proxmox/main/01_Install/optional.sh | bash

```
---

## Network Configuration - Link aggregation
* This configuration may be different depending on the number of NICs your team has. In my experience and needs, I have found it quite useful to unify all the available cards into one to avoid bottlenecks by creating more "lanes", and connect all the VMs to a single interface.
* I do all of this from the GUI in each NODE:
  * PVE
    * System -> Network
    * Remove but **don't apply** the changes yet = vmbr0 (Linux Bridge)
      * **CREATE -> Linux Bond**
        * Autostart: :heavy_check_mark:
        * Slaves: `[all your Network Devices separated by SPACE]`
        * Mode: `LACP (802.3ad)`
        * Hash Policy: `layer2+3`
      * **CREATE -> Linux Bridge**
        * IPv4/CIDR: `192.168.0.10/24`
        * Gateway: `192.168.0.1/24`
        * Autostart: :heavy_check_mark:
        * VLAN aware: :heavy_check_mark:
        * Bridge ports: `bond0`
      * Apply changes
  ### Cisco Switch - Link aggregation
  * The following changes were made from the cisco terminal where node was connected...
    ```bash
    conf t
    int port-channel 19
    switchport mode trunk
    switchport trunk native vlan 36
    switchport trunk allowed vlan 36,39,136
    end

    ###first port channel
    Cisco2960x_1: show run int port-channel 1
    Building configuration...

    Current configuration : 128 bytes
    !
    interface Port-channel1
    switchport trunk native vlan 36
    switchport trunk allowed vlan 36,39,136
    switchport mode trunk
    end

    ## now the ports
    Cisco2960x_1: show run int gi1/0/20      
    Building configuration...

    Current configuration : 186 bytes
    !
    interface GigabitEthernet1/0/20
    description Fideo 1
    switchport trunk native vlan 36
    switchport trunk allowed vlan 36,39,136
    switchport mode trunk
    channel-group 1 mode active
    end


    ### check the following
    Cisco2960x_1: show etherchannel summary 
    Flags:  D - down        P - bundled in port-channel
            I - stand-alone s - suspended
            H - Hot-standby (LACP only)
            R - Layer3      S - Layer2
            U - in use      f - failed to allocate aggregator

            M - not in use, minimum links not met
            u - unsuitable for bundling
            w - waiting to be aggregated
            d - default port


    Number of channel-groups in use: 1
    Number of aggregators:           1

    Group  Port-channel  Protocol    Ports
    ------+-------------+-----------+-----------------------------------------------
    1      Po1(SU)         LACP      Gi1/0/20(P) Gi1/0/21(P) Gi1/0/22(P) 
                                    Gi1/0/23(P)



    ##source
    ##https://www.youtube.com/watch?v=qRlJjC1jpqA

    ```

  ### Unifi Link aggregation
    * The following changes were made from the GUI unifi controller where node was connected...
    * It is important to remember that the ports are one after the other.
    * UniFi Switch
      * Edit ports
        * Profile overrides -> **Aggregate** :heavy_check_mark:
          * select the ports range
          * Apply



## Cluster
* After having two or more installations ready, open the main node (GUI).
  * Datacenter
    * Cluster
      * **Create Cluster**
* I do all of this from the GUI in each NODE:
  * 
