[![Docker Build Status](https://img.shields.io/docker/build/jumpserver/guacamole.svg?style=for-the-badge)](https://hub.docker.com/r/jumpserver/guacamole/)
[![Docker Pulls](https://img.shields.io/docker/pulls/jumpserver/guacamole.svg?style=for-the-badge)](https://hub.docker.com/r/jumpserver/guacamole/)

# Docker Guacamole

A Docker Container for [Apache Guacamole](https://guacamole.incubator.apache.org/), a client-less remote desktop gateway. It supports standard protocols like VNC, RDP, and SSH over HTML5.

This container runs the guacamole web client, the guacd server for jumpserver.

## Usage

```shell
docker run \
  -p 8081:8081 \
  -e JUMPSERVER_SERVER=http://<jumpserver>:8080 \
  -e BOOTSTRAP_TOKEN=<jumpserver token> \
  jumpserver/jms_guacamole
```

## Nginx Configure

please add the following configure in you nginx config.

```
location /guacamole/ {
    proxy_pass http://<guacamole>:8081/;
}
```
