# Makefile para o Analisador Léxico

CC = gcc
CFLAGS = -Wall -g

all: goianinha

goianinha.c: goianinha.l
	flex -o goianinha.c goianinha.l

goianinha: goianinha.c main.c
	$(CC) $(CFLAGS) -o goianinha goianinha.c main.c -lfl

clean:
	rm -f goianinha.c goianinha