#!/bin/bash

# disable SELinux
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

# disable swap
sudo sed -i '/swap/d' /etc/fstab
sudo swapoff -a