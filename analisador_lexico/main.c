#include <stdio.h>
#include <stdlib.h>

// Declarações externas
extern FILE *yyin;
extern int yylineno;
extern char* yytext;
extern int yylex();

int main(int argc, char *argv[]) {
    int token;
    
    // Verificar se foi fornecido o nome do arquivo
    if (argc != 2) {
        fprintf(stderr, "Uso: %s arquivo_fonte.g\n", argv[0]);
        exit(1);
    }
    
    // Abrir o arquivo de entrada
    yyin = fopen(argv[1], "r");
    if (yyin == NULL) {
        fprintf(stderr, "Erro ao abrir o arquivo %s\n", argv[1]);
        exit(1);
    }
    
    // Loop para processar todos os tokens
    while ((token = yylex()) != EOF) {
        printf("Encontrado o lexema %s pertencente ao token de codigo %d linha %d\n", 
               yytext, token, yylineno);
    }
    
    // Fechar o arquivo
    fclose(yyin);
    
    return 0;
}