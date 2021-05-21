#!/bin/bash

while getopts h:i: option
do
case "${option}"
in
h) HOSTNAME=${OPTARG};;
i) IPADDRESS=${OPTARG};;
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

# add worker hostname to /etc/hosts
cat >> /etc/hosts <<EOF
$IPADDRESS $HOSTNAME
EOF