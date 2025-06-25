# O compilador C 
CC = gcc
# Flags do compilador: -g para incluir informações de depuração, -Wall para mostrar todos os warnings.
CFLAGS = -g -Wall

# A ferramenta para gerar o analisador léxico
LEX = flex
# A ferramenta para gerar o analisador sintático
YACC = bison
# Flags para o YACC: -d é essencial para criar o arquivo de cabeçalho (.h) com a definição dos tokens.
YFLAGS = -d

# O nome do nosso programa executável final
TARGET = goianinha_compiler

# --- Arquivos do Projeto ---

# Nossos arquivos fonte .c escritos manualmente.
SRCS = main.c ast.c symboltable.c semantic.c

# Lista de todos os arquivos objeto (.o) que serão gerados.
# O Makefile substitui automaticamente a extensão .c por .o.
OBJS = $(SRCS:.c=.o) goianinha.tab.o lex.yy.o


# --- Regras (Targets) ---

# O alvo 'all' é o padrão. Quando você digita apenas 'make', é isso que ele executa.
# Ele depende do nosso executável final.
.PHONY: all
all: $(TARGET)

# Regra para criar o executável final.
# Ele depende de todos os arquivos objeto (.o).
# O comando linka todos os objetos para criar o alvo ($(TARGET)).
$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) -o $(TARGET) $(OBJS)

# Regra genérica para compilar arquivos .c para .o.
# Isso evita ter que escrever uma regra para cada arquivo .c.
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

# Regra para o analisador sintático (Bison)
# Gera goianinha.tab.c e goianinha.tab.h a partir de goianinha.y
goianinha.tab.c goianinha.tab.h: goianinha.y
	$(YACC) $(YFLAGS) goianinha.y

# Regra para o analisador léxico (Flex)
# Gera lex.yy.c a partir de goianinha.l
# Dependência CRÍTICA: depende de goianinha.tab.h porque precisa saber os nomes dos tokens.
lex.yy.c: goianinha.l goianinha.tab.h
	$(LEX) goianinha.l


.PHONY: clean
clean:
	rm -f $(TARGET) $(OBJS) lex.yy.c goianinha.tab.c goianinha.tab.h

