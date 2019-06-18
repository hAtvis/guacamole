FROM library/tomcat:9-jre8

WORKDIR /config

ENV GUAC_VER=1.0.0

RUN set -ex \
    && apt-get update \
    && apt-get install -y libcairo2-dev libjpeg62-turbo-dev libpng-dev libossp-uuid-dev libavcodec-dev libavutil-dev libswscale-dev libfreerdp-dev libpango1.0-dev libssh2-1-dev libtelnet-dev libvncserver-dev libpulse-dev libssl-dev libvorbis-dev libwebp-dev ghostscript git \
    && ln -s /usr/local/lib/freerdp /usr/lib/x86_64-linux-gnu/freerdp \
    && mkdir -p /config/guacamole /config/guacamole/lib /config/guacamole/extensions \
    && sed -i 's/Connector port="8080"/Connector port="8081"/g' /usr/local/tomcat/conf/server.xml \
    && sed -i 's/level = FINE/level = WARNING/g' /usr/local/tomcat/conf/logging.properties \
    && echo "java.util.logging.ConsoleHandler.encoding = UTF-8" >> /usr/local/tomcat/conf/logging.properties \
    && git clone https://github.com/jumpserver/docker-guacamole.git \
    && ln -sf /config/docker-guacamole/guacamole-${GUAC_VER}.war /usr/local/tomcat/webapps/ROOT.war \
    && ln -sf /config/docker-guacamole/guacamole-auth-jumpserver-${GUAC_VER}.jar /config/guacamole/extensions/guacamole-auth-jumpserver-${GUAC_VER}.jar \
    && ln -sf /config/docker-guacamole/root/app/guacamole/guacamole.properties /config/guacamole/guacamole.properties \
    && cd /config/docker-guacamole \
    && tar xf guacamole-server-${GUAC_VER}.tar.gz \
    && cd guacamole-server-${GUAC_VER} \
    && ./configure \
    && make \
    && make install \
    && cd .. \
    && rm -rf guacamole-server-${GUAC_VER} \
    && wget https://github.com/ibuler/ssh-forward/releases/download/v0.0.5/linux-amd64.tar.gz \
    && tar xf linux-amd64.tar.gz -C /bin/ \
    && chmod +x /bin/ssh-forward \
    && rm -rf /config/linux-amd64.tar.gz \
    && apt-get autoremove -y \
    && apt-get autoclean \
    && rm -rf /var/lib/apt/lists/*

COPY readme.txt /config/readme.txt
COPY entrypoint.sh /bin/entrypoint.sh
RUN chmod +x /bin/entrypoint.sh

ENV JUMPSERVER_KEY_DIR=/config/guacamole/keys \
    GUACAMOLE_HOME=/config/guacamole \
    JUMPSERVER_ENABLE_DRIVE=true \
    JUMPSERVER_SERVER=http://127.0.0.1:8080 \
    BOOTSTRAP_TOKEN=KXOeyNgDeTdpeu9q

VOLUME /config/guacamole/keys

EXPOSE 8081
ENTRYPOINT ["entrypoint.sh"]
