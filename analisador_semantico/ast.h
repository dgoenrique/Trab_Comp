#ifndef AST_H
#define AST_H

#include <stdio.h>
#include "symboltable.h" 

// Tipos de nós possíveis na AST
typedef enum {
    // NÓS DE DECLARAÇÃO
    AST_DECL_VAR,          // Declaração de variável (ex int a, b;)
    AST_DECL_FUNC,         // Declaração de função
    AST_LISTA_PARAM,       // Lista de parâmetros de uma função
    AST_TIPO,              // Nó para representar um tipo (ex int, car)

    // NÓS DE COMANDO
    AST_BLOCO,             // Representa um  bloco (ex { ... })
    AST_LISTA_COMANDOS,    // Sequência de comandos
    AST_SE,                // Comando if (com ou sem else)
    AST_ENQUANTO,          // Comando while
    AST_ATRIBUICAO,        // a = 10
    AST_RETORNE,           // retorne
    AST_LEIA,              // leia id
    AST_ESCREVA,           // escreva 
    AST_NOVALINHA,

    // NÓS DE EXPRESSÃO
    AST_CHAMADA_FUNCAO,    // f(a, b)
    AST_LISTA_EXPR,        // Lista de expressões (argumentos de função)
    // Operadores Binários
    AST_SOMA, AST_SUB, AST_MULT, AST_DIV,
    AST_IGUAL_IGUAL, AST_DIFERENTE, AST_MENOR, AST_MAIOR, AST_MENOR_IGUAL, AST_MAIOR_IGUAL,
    AST_E, AST_OU,
    // Operadores Unários
    AST_MENOS_UNARIO, AST_NAO,

    // NÓS FOLHA (TERMINAIS)
    AST_ID,                // Identificador (nome de variável/função)
    AST_CONST_INT,         // Literal inteiro
    AST_CONST_CHAR,        // Literal char
    AST_STRING,            // Literal string para o comando escreva

} NodeType;


// Estrutura do Nó da AST 
typedef struct ast_node {
    NodeType type;                  // O tipo do nó, vindo do enum acima
    int linha;                      // A linha do código fonte, para mensagens de erro
    char* valor;                    // Valor léxico (ex: nome do ID, valor do inteiro)
    
    // Ponteiro para a entrada na Tabela de Símbolos.
    SymbolEntry* simbolo;

    // Usamos 4 filhos para ter flexibilidade.
    // if-then-else usa 3, um for usaria 4. A maioria usa 1 ou 2.
    
    // Filhos do nó. 4 para ser usado por tudo  (if, for ...)
    struct ast_node *p1, *p2, *p3, *p4; 
} ASTNode;



//Cria um novo nó da AST 
ASTNode* ast_criar_no(NodeType type, char* valor, int linha, ASTNode* p1, ASTNode* p2, ASTNode* p3, ASTNode* p4);

// Libera toda a memória alocada 
void ast_liberar(ASTNode* no);

// Imprime a árvore no console (para depuração).
void ast_imprimir(ASTNode* no, int nivel);

#endif // AST_H