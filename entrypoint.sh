#!/bin/bash
#

/usr/local/guacamole/sbin/guacd &
cd /config/tomcat8/bin && ./startup.sh
tail -f /config/readme.txt
