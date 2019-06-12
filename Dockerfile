FROM guacamole/guacd:1.0.0
LABEL maintainer "wojiushixiaobai"
WORKDIR /config

ENV GUAC_VER=1.0.0 \
    TOMCAT_VER=9.0.20

RUN set -ex \
    && apt-get update \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && apt-get install -y openjdk-8-jdk openjdk-8-jre git wget \
    && mkdir -p /config/guacamole /config/guacamole/lib /config/guacamole/extensions \
    && wget http://mirrors.tuna.tsinghua.edu.cn/apache/tomcat/tomcat-9/v${TOMCAT_VER}/bin/apache-tomcat-${TOMCAT_VER}.tar.gz \
    && tar xf apache-tomcat-${TOMCAT_VER}.tar.gz \
    && mv apache-tomcat-${TOMCAT_VER} tomcat9 \
    && rm -rf apache-tomcat-${TOMCAT_VER}.tar.gz \
    && rm -rf tomcat9/webapps/* \
    && sed -i 's/Connector port="8080"/Connector port="8081"/g' /config/tomcat9/conf/server.xml \
    && sed -i 's/level = FINE/level = WARNING/g' /config/tomcat9/conf/logging.properties \
    && echo "java.util.logging.ConsoleHandler.encoding = UTF-8" >> /config/tomcat9/conf/logging.properties \
    && git clone https://github.com/jumpserver/docker-guacamole.git \
    && ln -sf /config/docker-guacamole/guacamole-${GUAC_VER}.war /config/tomcat9/webapps/ROOT.war \
    && ln -sf /config/docker-guacamole/guacamole-auth-jumpserver-${GUAC_VER}.jar /config/guacamole/extensions/guacamole-auth-jumpserver-${GUAC_VER}.jar \
    && ln -sf /config/docker-guacamole/root/app/guacamole/guacamole.properties /config/guacamole/guacamole.properties \
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
