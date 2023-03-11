.PHONY: all
all:
	docker build --network host . -t beshleman/makevm:latest

