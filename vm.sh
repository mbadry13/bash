#/bin/bash
## Script Variables ##

BLACK="\033[30m"
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
PINK="\033[35m"
CYAN="\033[36m"
WHITE="\033[37m"
NORMAL="\033[0;39m"
NIC=$(nmcli -g name connection show)
UUID="$uuidgen ens192"


############################################
######## To Configure Hostname #############
############################################

echo -e $GREEN "What is the Machine Hostname:" ; read hostnameset
hostnamectl set-hostname $hostnameset
echo -e $GREEN "What is the IP address" ; read IP
echo -e $GREEN "What is the Subnetmask" ; read MASK
echo -e $GREEN "What is the Gateway" ; read GW
echo -e $GREEN "Configuring Hostname"
############################################
############ Configure Network #############
############################################
sleep 3

sed -i '/UUID/d' /etc/sysconfig/network-scripts/ifcfg-$NIC
sed -i '/IPADDR/d' /etc/sysconfig/network-scripts/ifcfg-$NIC
sed -i '/PREFIX/d' /etc/sysconfig/network-scripts/ifcfg-$NIC
sed -i '/GATEWAY/d' /etc/sysconfig/network-scripts/ifcfg-$NIC
sed -i '/BOOTPROTO/d' /etc/sysconfig/network-scripts/ifcfg-$NIC
echo BOOTPROTO=static >> /etc/sysconfig/network-scripts/ifcfg-$NIC
echo IPADDR=$IP >> /etc/sysconfig/network-scripts/ifcfg-$NIC
echo MASK=$MASK >> /etc/sysconfig/network-scripts/ifcfg-$NIC
echo GATEWAY=$GW >> /etc/sysconfig/network-scripts/ifcfg-$NIC
echo UUID=$UUID >> /etc/sysconfig/network-scripts/ifcfg-ens192
nmcli networking off && nmcli networking on
systemctl restart NetworkManager
echo -e "Configuring Network for $NIC"
#echo -ne '############# (66%)\r'

sleep 3
################################################
#### Resetting and Deleting system-users ######
################################################

echo -e $GREEN Deleting existing non-systems users
sleep 3
awk -F: '($3>=1000)&&($1!="nobody"){print $1}' /etc/passwd > /tmp/test.txt
for USERS in $(cat /tmp/test.txt); do userdel -r $USERS; done
sleep 3

################################################
##########  Reseting SSH-Keys for root #########
################################################
echo -e $WHITE "Reset and Regenrate ssh-keys for $USER"
ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa <<<y >/dev/null 2>&1
sleep 2

################################################
##########  Reseting udev rules       #########
################################################

echo -e $WHITE " Reseting udev rules"

sbin/udevadm control --reload-rules

/sbin/udevadm trigger --type=devices --action=change

echo -e $RED "Please reconnect the session using the new ip $IP"

###################################################
######## Remove and Clean Satellite Registeration##
###################################################

echo -e $GREEN "Unregister the system from The satellite if any"

subscription-manager unregister
subscription-manager clean

###################################################
########### Satellite Registeration################
###################################################
echo -e $GREEN " Registering to the Satellite"
sleep 2

nmcli con down $NIC && nmcli con up $NIC

echo -e $WHITE" Machine hostname is $(hostname) and ip address is $(ip addr show scope global | awk '$1 ~ /^inet/ {print $2}')"
echo -e $RED "Please use this command to login to the server ssh root@$IP"
