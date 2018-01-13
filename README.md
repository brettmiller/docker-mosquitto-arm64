Docker Mosquitto for arm64/aarch64
====
Docker build file for mosquitto (MQTT) on arm64/aarch64. This docker file is based on
ubuntu 16.04 and mosquitto version 1.4.14. Provides a simple configuration 
that enables the default listner and the websockets listner. 

Run it
====
### Run it with something like:

    $ docker run --name=mosquitto \
     -p 1883:1883 \
     -p 9001:9001 \
     -v /etc/localtime:/etc/localtime:ro \
     -v /etc/timezone:/etc/timezone:ro \
     --mount source=mosquitto-config,destination=/mosquitto/config \
     --mount source=mosquitto-data,destination=/mosquitto/data \
     --mount source=mosquitto-log,destination=/mosquitto/log \
     -u mosquitto \
     mosquitto-arm64
