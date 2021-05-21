#!/bin/bash

while getopts h:i:t: option
do
case "${option}"
in
h) HOSTNAME=${OPTARG};;
i) IPADDRESS=${OPTARG};;
t) NODETYPE=${OPTARG};;
esac
done

if [[ -z $HOSTNAME ]];
then
    echo `date`" - missing hostname parameter (-h)"
    exit 1
fi

if [[ -z $IPADDRESS ]];
then
    echo `date`" - missing ip address parameter (-i)"
    exit 1
fi

if [ $NODETYPE != "master" ] && [ $NODETYPE != "worker" ]
then 
    echo `date`" - type must be either master or worker"
    exit 1
fi

# set hostname
hostnamectl set-hostname $HOSTNAME

# add hostname to /etc/hosts
cat >> /etc/hosts <<EOF
$IPADDRESS $HOSTNAME
EOF

# set /proc/sys/net/bridge/bridge-nf-call-iptables to 1
sudo sysctl net.bridge.bridge-nf-call-iptables=1

# configure firewall
firewall-cmd --permanent --add-port=6443/tcp
firewall-cmd --permanent --add-port=2379-2380/tcp
firewall-cmd --permanent --add-port=10250/tcp
firewall-cmd --permanent --add-port=10251/tcp
firewall-cmd --permanent --add-port=10252/tcp
firewall-cmd --permanent --add-port=10255/tcp
firewall-cmd --permanent --add-port=8472/udp
firewall-cmd --permanent --add-port=30000-32767/tcp
firewall-cmd --add-masquerade --permanent
systemctl restart firewalld

