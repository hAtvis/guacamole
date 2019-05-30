#!/bin/bash
#

localedef -c -f UTF-8 -i zh_CN zh_CN.UTF-8
export LC_ALL=zh_CN.UTF-8

guacd &
cd /config/tomcat8/bin && ./startup.sh
tail -f /config/readme.txt
