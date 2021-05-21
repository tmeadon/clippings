#!/bin/bash
mv /tmp/image-files /opt/image-files
find /opt/image-files -type f -iname "*.sh" -exec chmod +x {} \;