#include <stdio.h>
#include <stdlib.h>
#include "semantic.h"
#include "symboltable.h" 

//Pilha global de tabelas de símbolos (uma por escopo)
static SymbolTableStack tabela_simbolos;

// Protótipos das funções internas 
static void percorrer_no(ASTNode* no);
static int get_expr_type(ASTNode* no);
static SymbolEntry* search_symbol_in_current_scope(SymbolTable* table, char* name);

// Função de erro semântico centralizada
static void erro_semantico(const char* mensagem, int linha) {
    fprintf(stderr, "ERRO SEMÂNTICO [linha %d]: %s\n", linha, mensagem);
    exit(1); // Encerra a compilação 
}


// Função principal chamada pelo main.c
void analisar_semanticamente(ASTNode* raiz) {
    if (!raiz) return;
    
    //inicializa a pilha
    init_symbol_table_stack(&tabela_simbolos);
    create_new_scope(&tabela_simbolos); // Cria o escopo global

    percorrer_no(raiz); //inicia a analise semantica

    remove_current_scope(&tabela_simbolos); // Remove o escopo global
}

// Retorna o tipo de uma expressão para validacao
static int get_expr_type(ASTNode* no) {
    if (!no) return 0; // 0  = sem tipo ou vazio

    int tipo_p1, tipo_p2;

    switch (no->type) {
        case AST_CONST_INT: return TYPE_INT;
        case AST_CONST_CHAR: return TYPE_CHAR;
        case AST_ID:
            if (no->simbolo) {
                //retorna o tipo associado na tabela
                return no->simbolo->data_type;
            }
           /// caso o simbolo não está presente, outro erro semântico será lançado
            return 0;

        // Operadores Aritméticos (int)
        case AST_SOMA:
        case AST_SUB:
        case AST_MULT:
        case AST_DIV:
            tipo_p1 = get_expr_type(no->p1);
            tipo_p2 = get_expr_type(no->p2);
            if (tipo_p1 != TYPE_INT || tipo_p2 != TYPE_INT) {
                erro_semantico("Operadores aritméticos exigem operandos do tipo 'int'.", no->linha);
            }
            return TYPE_INT;

        // Operadores Relacionais (mesmo tipo e retorna int)
        case AST_IGUAL_IGUAL:
        case AST_DIFERENTE:
        case AST_MENOR:
        case AST_MAIOR:
        case AST_MENOR_IGUAL:
        case AST_MAIOR_IGUAL:
            tipo_p1 = get_expr_type(no->p1);
            tipo_p2 = get_expr_type(no->p2);
            if (tipo_p1 != tipo_p2) {
                erro_semantico("Operadores relacionais exigem operandos de mesmo tipo.", no->linha);
            }
            return TYPE_INT; 

        // Operadores Lógicos (retorna int)
        case AST_E:
        case AST_OU:
            return TYPE_INT;
        
        case AST_CHAMADA_FUNCAO:
            //chamada da funcao - se der tempo fazer para retornar o tipo de retorno
            return 0; 

        default:
            return 0; // Tipo desconhecido ou nao é uma expressõa
    }
}


// Função recursiva principal que percorre a árvore
static void percorrer_no(ASTNode* no) {
    if (!no) return;

    // Ações pré-ordem (antes de visitar os filhos)
    switch (no->type) {
        case AST_BLOCO:
            create_new_scope(&tabela_simbolos); // Entra em um novo escopo 
            break;

        case AST_DECL_VAR: {
            ASTNode* tipo_node = no->p1;
            ASTNode* id_node = no->p2;
            int data_type = (strcmp(tipo_node->valor, "int") == 0) ? TYPE_INT : TYPE_CHAR;
            
            //ve se já existe variável com mesmo nome no escopo local
            SymbolEntry* existente = search_symbol_in_current_scope(tabela_simbolos.top, id_node->valor);
            if (existente) {
                char msg[100];
                sprintf(msg, "Variável '%s' já declarada neste escopo.", id_node->valor);
                erro_semantico(msg, id_node->linha);
            }
            
            //insere na tabela de símbolos e salva refer^cia do nó
            id_node->simbolo = insert_variable(&tabela_simbolos, id_node->valor, data_type, 0);
            if (!id_node->simbolo) {
                erro_semantico("Falha ao alocar memória para símbolo na tabela.", id_node->linha);
            }
            break;
        }
    }

    // Processamento específico do nó (pós-ordem para expressões/atribuições)
    switch (no->type) {
        case AST_ATRIBUICAO: {
            percorrer_no(no->p1); // Processa o lado esquerdo (ID)
            percorrer_no(no->p2); // Processa o lado direito (Expressão)
            
            int tipo_esq = get_expr_type(no->p1);
            int tipo_dir = get_expr_type(no->p2);
            
            // tem que ser do mesmo tipo
            if (tipo_esq != tipo_dir) {
                erro_semantico("Tipos incompatíveis na atribuição.", no->linha);
            }
            break;
        }

        case AST_ID: {
            //valida se a vaiável foi declarada em escopos anteriores
            SymbolEntry* simbolo = search_symbol(&tabela_simbolos, no->valor);
            if (!simbolo) {
                char msg[100];
                sprintf(msg, "Variável '%s' não declarada.", no->valor);
                erro_semantico(msg, no->linha);
            }
            // salva ponteiro para o símbolo na AST
            no->simbolo = simbolo;
            break;
        }

        case AST_SE:
        case AST_ENQUANTO:
            percorrer_no(no->p1); // Processa a condição
            get_expr_type(no->p1); //tipo válido (int)
            percorrer_no(no->p2); // Processa o corpo (then/execute)
            percorrer_no(no->p3); // Processa o else, se tiver
            break;
        
        default:
            // para os outros casos, apenas visita os filhos recursivamente.
            percorrer_no(no->p1);
            percorrer_no(no->p2);
            percorrer_no(no->p3);
            percorrer_no(no->p4);
            break;
    }

    if (no->type == AST_BLOCO) {
        remove_current_scope(&tabela_simbolos); // Sai do escopo
    }
}

// busca um s´mibolo no escopo atual sem verificar os anteriores
static SymbolEntry* search_symbol_in_current_scope(SymbolTable* table, char* name) {
    if (!table) return NULL;
    SymbolEntry* current_entry = table->first;
    while (current_entry != NULL) {
        if (strcmp(current_entry->name, name) == 0) {
            return current_entry;
        }
        current_entry = current_entry->next;
    }
    return NULL;
}