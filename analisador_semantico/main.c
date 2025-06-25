// Arquivo: main.c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Nossos módulos do compilador
#include "ast.h"
#include "semantic.h"
// #include "codegen.h" // Futuramente, para a geração de código

// Globais do Flex e Bison
extern int yyparse();
extern FILE* yyin;
extern ASTNode* arvore_abstrata;

int main(int argc, char* argv[]) {
    // --- 1. Verificação dos Argumentos ---
    if (argc < 2) {
        fprintf(stderr, "ERRO: Arquivo de entrada não especificado.\n");
        fprintf(stderr, "Uso: %s <arquivo_de_entrada.goi>\n", argv[0]);
        return 1;
    }

    // --- 2. Abertura do Arquivo de Entrada ---
    yyin = fopen(argv[1], "r");
    if (yyin == NULL) {
        fprintf(stderr, "ERRO: Não foi possível abrir o arquivo '%s'.\n", argv[1]);
        return 1;
    }

    printf(">>> Iniciando compilação de '%s'...\n", argv[1]);

    // --- 3. FASE 1: Análise Sintática e Construção da AST ---
    printf(">>> Fase 1: Análise Sintática...\n");
    if (yyparse() != 0) {
        // A função yyerror() dentro do .y já terá impresso o erro.
        fprintf(stderr, "Compilação falhou na análise sintática.\n");
        fclose(yyin);
        return 1;
    }
    printf("Análise Sintática concluída com sucesso.\n");

    // --- 4. FASE 2: Análise Semântica ---
    printf(">>> Fase 2: Análise Semântica...\n");
    analisar_semanticamente(arvore_abstrata);
    // A função analisar_semanticamente() encerra o programa se encontrar erros.
    printf("Análise Semântica concluída com sucesso.\n");
    
    // --- 5. FASE 3: Geração de Código (Ainda não implementada) ---
    printf(">>> Fase 3: Geração de Código...\n");
    // FILE* arquivo_saida = fopen("output.asm", "w");
    // if (!arquivo_saida) {
    //     fprintf(stderr, "ERRO: Não foi possível criar o arquivo de saída.\n");
    //     return 1;
    // }
    // gerar_codigo(arvore_abstrata, arquivo_saida);
    // fclose(arquivo_saida);
    printf("Geração de Código (placeholder) concluída.\n");

    // --- 6. Limpeza e Encerramento ---
    printf(">>> Finalizando...\n");
    ast_liberar(arvore_abstrata);
    fclose(yyin);

    printf("Compilação concluída com sucesso!\n");
    return 0;
}