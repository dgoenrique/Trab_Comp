# Makefile para Tabela de Símbolos

CC = gcc
CFLAGS = -Wall -g

OBJS_ST = symboltable.o test_symboltable.o

all: test_symboltable

test_symboltable: $(OBJS_ST)
	$(CC) $(CFLAGS) -o test_symboltable $(OBJS_ST)

symboltable.o: symboltable.c symboltable.h
	$(CC) $(CFLAGS) -c symboltable.c

test_symboltable.o: test_symboltable.c symboltable.h
	$(CC) $(CFLAGS) -c test_symboltable.c

clean:
	rm -f *.o test_symboltable