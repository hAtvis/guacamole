#!/bin/bash
#

/usr/local/guacamole/sbin/guacd &
cd /config/tomcat9/bin && ./startup.sh
tail -f /config/readme.txt
