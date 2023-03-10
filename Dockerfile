FROM alpine:latest

RUN apk -U --no-cache upgrade
RUN apk add --no-cache lz4 wget cpio findutils sudo
RUN apk add --no-cache make git build-base

COPY ./makevm.sh /usr/local/bin/makevm.sh
ENTRYPOINT ["/usr/local/bin/makevm.sh"]
