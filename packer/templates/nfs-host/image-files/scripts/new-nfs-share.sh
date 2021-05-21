#!/bin/bash

while getopts d:h: option
do
case "${option}"
in
d) DIR=${OPTARG};;
h) HOST=${OPTARG};;
esac
done

if [[ -z $DIR ]];
then
    echo `date`" - missing share directory parameter (-d)"
    exit 1
fi

if [[ -z $HOST ]];
then
    HOST="*"
fi

if [[ -d "$DIR" ]]; then
    echo `date`" - directory already exists, please enter non-existent directory"
    exit 1
fi

# create the directory
mkdir $DIR
chown nfsnobody:nfsnobody $DIR
chmod 755 $DIR

# export the directory
echo "$DIR      $HOST(rw,no_root_squash,no_subtree_check)" >> /etc/exports
exportfs -a
