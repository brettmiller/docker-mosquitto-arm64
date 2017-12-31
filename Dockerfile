# Originally based on https://github.com/AnsgarSchmidt/Mosquitto
# converted to arb64 and multistage docker build

FROM arm64v8/ubuntu:16.04 as builder

ARG  MOSQUITTOVERSION
ENV  MOSQUITTOVERSION 1.4.14

MAINTAINER Brett Miller <brett@shadowed.net>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update   && \
    apt-get upgrade -y && \
    apt-get install -y wget build-essential libwrap0-dev libssl-dev python-distutils-extra \
             libc-ares-dev uuid-dev libwebsockets-dev 

RUN  mkdir -p /usr/local/src 
WORKDIR      /usr/local/src
RUN  wget http://mosquitto.org/files/source/mosquitto-$MOSQUITTOVERSION.tar.gz && \
     tar xvzf ./mosquitto-$MOSQUITTOVERSION.tar.gz
WORKDIR /usr/local/src/mosquitto-$MOSQUITTOVERSION
RUN make WITH_WEBSOCKETS=yes binary && mkdir /tmp/mosquitto && \
    DESTDIR=/tmp/mosquitto make install && rm -rf /tmp/mosquitto/usr/local/share

FROM arm64v8/ubuntu:16.04 as builder
RUN mkdir -p /mosquitto/config /mosquitto/data /mosquitto/log && \
    adduser --system --disabled-password --disabled-login mosquitto && \
    addgroup --system mosquitto && \
    chown -R mosquitto:mosquitto /mosquitto
COPY --from=builder /tmp/mosquitto/usr/local/* /usr/local/     
COPY config /mosquitto/config
USER  mosquitto

ENV PATH "$PATH:/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin"

EXPOSE 1883 8833 9001
COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["mosquitto", "-c", "/mosquitto/config/mosquitto.conf"]
