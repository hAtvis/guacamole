#!/bin/bash
#

export LANG="C.UTF-8"

guacd &
cd /config/tomcat8/bin && ./startup.sh
tail -f /config/readme.txt
