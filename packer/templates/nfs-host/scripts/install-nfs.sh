#!/bin/bash

# install and enable nfs
yum -y install nfs-utils
systemctl enable nfs-server.service

# create directory for nfs shares
mkdir /var/nfs
chown nfsnobody:nfsnobody /var/nfs
chmod 755 /var/nfs

