#!/bin/bash
#

rm -rf /config/guacamole/data/log/*
rm -rf /config/tomcat9/logs/*

guacd &
cd /config/tomcat9/bin && ./startup.sh

echo "Guacamole version 1.5.0, more see https://www.jumpserver.org"
Quit the server with CONTROL-C.
tail -f /config/guacamole/data/log/info.log
