Docker Mosquitto for arm64
=========
Docker build file for mosquitto (MQTT) on arm64. This docker file is based on
ubuntu 16.04 and mosquitto version 1.4.14


Run it
======
Run it with something like:

docker run --name=mosquitto \
  -p 1883:1883 \
  -p 9001:9001 \
  -v /etc/localtime:/etc/localtime:ro \
  -v /etc/timezone:/etc/timezone:ro \
  -v /opt/mosquitto.conf:/mosquitto/config \
  -v /opt/mosquitto/data:/mosquitto/data \
  -v /opt/mosquitto/log:/mosquitto/log \
  -u mosquitto \
  mosquitto-arm64 
