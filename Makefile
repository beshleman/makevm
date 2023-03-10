.PHONY: all
all:
	docker build --network host . -t makevm:latest

