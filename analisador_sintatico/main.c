#include <stdio.h>
#include <stdlib.h>

// Declaração das funções do analisador
extern int yyparse();
extern FILE* yyin;

int main(int argc, char** argv) {
    // Verifica se foi fornecido um arquivo de entrada
    if (argc < 2) {
        printf("Uso: ./goianinha arquivo.g\n");
        return 1;
    }

    // Abre o arquivo de entrada
    FILE* arquivo = fopen(argv[1], "r");
    if (!arquivo) {
        printf("ERRO: Não foi possível abrir o arquivo '%s'\n", argv[1]);
        return 1;
    }

    // Define o arquivo de entrada para o analisador léxico
    yyin = arquivo;

    // Executa a análise sintática
    int resultado = yyparse();

    // Fecha o arquivo
    fclose(arquivo);

    // Se não houve erro sintático, exibe mensagem de sucesso
    if (resultado == 0) {
        printf("Análise sintática concluída com sucesso.\n");
    }

    return resultado;
}