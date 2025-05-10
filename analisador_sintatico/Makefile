# Makefile para compilação do analisador léxico e sintático da linguagem Goianinha

# Compilador e flags
CC = gcc
CFLAGS = -Wall -g

# Arquivos gerados
LEX_C = lex.yy.c
YACC_C = y.tab.c
YACC_H = y.tab.h

# Executável
TARGET = goianinha

# Regra principal
all: $(TARGET)

# Gerar o analisador léxico usando flex
$(LEX_C): goianinha.l $(YACC_H)
	flex goianinha.l

# Gerar o analisador sintático usando bison
$(YACC_C) $(YACC_H): goianinha.y
	bison -d -y goianinha.y

# Compilar e linkar o programa
$(TARGET): $(LEX_C) $(YACC_C) main.c
	$(CC) $(CFLAGS) -o $(TARGET) main.c $(LEX_C) $(YACC_C)

# Limpar arquivos gerados
clean:
	rm -f $(LEX_C) $(YACC_C) $(YACC_H) $(TARGET)

# Regra para facilitar a reconstrução completa
rebuild: clean all

.PHONY: all clean rebuild