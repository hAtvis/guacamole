FROM centos:latest
LABEL maintainer "wojiushixiaobai"
WORKDIR /config

ENV LC_ALL=en_US.UTF-8 \
    GUAC_VER=1.0.0 \
    TOMCAT_VER=9.0.21

RUN set -ex \
    && yum -y install epel-release \
    && curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo \
    && curl -o /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo \
    && yum makecache \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && mkdir /usr/local/lib/freerdp/ \
    && ln -s /usr/local/lib/freerdp /usr/lib64/freerdp \
    && rpm --import http://li.nux.ro/download/nux/RPM-GPG-KEY-nux.ro \
    && rpm -Uvh http://li.nux.ro/download/nux/dextop/el7/x86_64/nux-dextop-release-0-5.el7.nux.noarch.rpm \
    && yum -y localinstall --nogpgcheck https://mirrors.aliyun.com/rpmfusion/free/el/rpmfusion-free-release-7.noarch.rpm https://mirrors.aliyun.com/rpmfusion/nonfree/el/rpmfusion-nonfree-release-7.noarch.rpm \
    && yum install -y make gcc libtool java-1.8.0-openjdk git wget \
    && yum install -y cairo-devel libjpeg-turbo-devel libpng-devel uuid-devel \
    && yum install -y ffmpeg-devel freerdp-devel freerdp-plugins pango-devel libssh2-devel libtelnet-devel libvncserver-devel pulseaudio-libs-devel openssl-devel libvorbis-devel libwebp-devel ghostscript \
    && mkdir -p /config/guacamole /config/guacamole/lib /config/guacamole/extensions /config/guacamole/data/log/ \
    && wget http://mirrors.tuna.tsinghua.edu.cn/apache/tomcat/tomcat-9/v${TOMCAT_VER}/bin/apache-tomcat-${TOMCAT_VER}.tar.gz \
    && tar xf apache-tomcat-${TOMCAT_VER}.tar.gz \
    && mv apache-tomcat-${TOMCAT_VER} tomcat9 \
    && rm -rf apache-tomcat-${TOMCAT_VER}.tar.gz \
    && rm -rf tomcat9/webapps/* \
    && sed -i 's/Connector port="8080"/Connector port="8081"/g' /config/tomcat9/conf/server.xml \
    && sed -i 's/level = FINE/level = OFF/g' /config/tomcat9/conf/logging.properties \
    && sed -i 's/level = INFO/level = OFF/g' /config/tomcat9/conf/logging.properties \
    && sed -i 's@CATALINA_OUT="$CATALINA_BASE"/logs/catalina.out@CATALINA_OUT=/dev/null@g' /config/tomcat9/bin/catalina.sh \
    && sed -i 's/# export/export/g' /root/.bashrc \
    && sed -i 's/# alias l/alias l/g' /root/.bashrc \
    && echo "java.util.logging.ConsoleHandler.encoding = UTF-8" >> /config/tomcat9/conf/logging.properties \
    && git clone --depth=1 https://github.com/jumpserver/docker-guacamole.git \
    && cd /config/docker-guacamole \
    && tar xf guacamole-server-${GUAC_VER}.tar.gz \
    && cd guacamole-server-${GUAC_VER} \
    && autoreconf -fi \
    && ./configure --with-init-dir=/etc/init.d \
    && make \
    && make install \
    && ldconfig \
    && cd .. \
    && rm -rf guacamole-server-${GUAC_VER} \
    && ln -sf /config/docker-guacamole/guacamole-${GUAC_VER}.war /config/tomcat9/webapps/ROOT.war \
    && ln -sf /config/docker-guacamole/guacamole-auth-jumpserver-${GUAC_VER}.jar /config/guacamole/extensions/guacamole-auth-jumpserver-${GUAC_VER}.jar \
    && ln -sf /config/docker-guacamole/root/app/guacamole/guacamole.properties /config/guacamole/guacamole.properties \
    && wget https://github.com/ibuler/ssh-forward/releases/download/v0.0.5/linux-amd64.tar.gz \
    && tar xf linux-amd64.tar.gz -C /bin/ \
    && chmod +x /bin/ssh-forward \
    && rm -rf /config/linux-amd64.tar.gz \
    && yum -y autoremove autoconf automake cairo-devel freerdp-devel gcc libjpeg-turbo-devel libssh2-devel libtool libtelnet-devel libvorbis-devel libvncserver-devel make pango-devel pulseaudio-libs-devel \
    && yum clean all \
    && rm -rf /var/cache/yum/*

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
