#!/bin/bash

firewall-cmd --permanent --zone=public --add-service=nfs
firewall-cmd --reload
