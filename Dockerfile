FROM beshleman/debian-kernel:latest

COPY ./makevm.sh /usr/local/bin/makevm.sh

ENTRYPOINT ["/usr/local/bin/makevm.sh"]
