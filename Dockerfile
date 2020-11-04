# Originally based on https://github.com/AnsgarSchmidt/Mosquitto
# converted to arb64 and multistage docker build

FROM arm64v8/ubuntu:18.04 as builder

ARG  MOSQUITTOVERSION
ENV  MOSQUITTOVERSION 1.5.3

LABEL maintainer="Brett Miller <brett@shadowed.net>, Jesse Stuart <hi@jessestuart.com>"

ENV DEBIAN_FRONTEND noninteractive

RUN \
  apt-get update && \
  apt-get upgrade -y && \
  apt-get install -y \
    build-essential libwrap0-dev libssl-dev python-distutils-extra \
    libc-ares-dev uuid-dev libwebsockets-dev wget

RUN  mkdir -p /usr/local/src
WORKDIR      /usr/local/src
RUN  wget http://mosquitto.org/files/source/mosquitto-$MOSQUITTOVERSION.tar.gz && \
     tar xvzf ./mosquitto-$MOSQUITTOVERSION.tar.gz
WORKDIR /usr/local/src/mosquitto-$MOSQUITTOVERSION
RUN make WITH_WEBSOCKETS=yes binary && mkdir /tmp/mosquitto && \
    DESTDIR=/tmp/mosquitto make install && rm -rf /tmp/mosquitto/usr/local/share

FROM arm64v8/ubuntu:18.04
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y libssl1.1 libc-ares2 libuuid1 libwebsockets8 && \
    apt-get clean
RUN mkdir -p /usr/local /mosquitto/config /mosquitto/data /mosquitto/log && \
    useradd --system --no-create-home -s /usr/sbin/nologin -U mosquitto && \
    chown -R mosquitto:mosquitto /mosquitto
COPY --from=builder /tmp/mosquitto/usr/local/ /usr/local/
COPY config /mosquitto/config
USER  mosquitto

ENV PATH "$PATH:/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin"

EXPOSE 1883 8833 9001
COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["/usr/local/sbin/mosquitto", "-c", "/mosquitto/config/mosquitto.conf"]
