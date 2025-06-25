#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"

// Vetro com os nomes de cada tipo de nó
// A ordem é a mesma do enum em ast.h!
const char* NODE_TYPE_NAMES[] = {
    "DECL_VAR", "DECL_FUNC", "LISTA_PARAM", "TIPO",
    "BLOCO", "LISTA_COMANDOS", "SE", "ENQUANTO", "ATRIBUICAO", "RETORNE", "LEIA", "ESCREVA", "NOVALINHA",
    "CHAMADA_FUNCAO", "LISTA_EXPR",
    "SOMA", "SUB", "MULT", "DIV",
    "IGUAL_IGUAL", "DIFERENTE", "MENOR", "MAIOR", "MENOR_IGUAL", "MAIOR_IGUAL",
    "E", "OU",
    "MENOS_UNARIO", "NAO",
    "ID", "CONST_INT", "CONST_CHAR", "STRING"
};

// Função para criar um novo nó da AST
ASTNode* ast_criar_no(NodeType type, char* valor, int linha, ASTNode* p1, ASTNode* p2, ASTNode* p3, ASTNode* p4) {
    ASTNode* no = (ASTNode*) malloc(sizeof(ASTNode));
    if (no == NULL) {
        fprintf(stderr, "Erro fatal: Falha na alocação de memória para o nó da AST na linha %d\n", linha);
        exit(1);
    }

    no->type = type;
    no->linha = linha;
    
    no->valor = valor ? strdup(valor) : NULL; // por causa de problemas no yytext
    
    // inicializa ponteiros
    no->simbolo = NULL; 
    no->p1 = p1;
    no->p2 = p2;
    no->p3 = p3;
    no->p4 = p4;
    
    return no;
}

// Libera a memória da árvore (pós-ordem)
void ast_liberar(ASTNode* no) {
    if (no == NULL) {
        return;
    }
    
    //Libera os filhos primeiro
    ast_liberar(no->p1);
    ast_liberar(no->p2);
    ast_liberar(no->p3);
    ast_liberar(no->p4);
    
    //Depois libera o valor (se existir) e o próprio nó
    if (no->valor) {
        free(no->valor);
    }
    free(no);
}

// Imprime a árvore( em pré-ordem)
void ast_imprimir(ASTNode* no, int nivel) {
    if (no == NULL) {
        return;
    }
    
    for (int i = 0; i < nivel; i++) {
        printf("  ");
    }
    
    // Imprime o tipo do nó e o valor 
    printf("[%s]", NODE_TYPE_NAMES[no->type]);
    if (no->valor) {
        printf(" (%s)", no->valor);
    }
    printf(" L:%d\n", no->linha);
    
    //chamada recursiva para os filhos
    ast_imprimir(no->p1, nivel + 1);
    ast_imprimir(no->p2, nivel + 1);
    ast_imprimir(no->p3, nivel + 1);
    ast_imprimir(no->p4, nivel + 1);
}