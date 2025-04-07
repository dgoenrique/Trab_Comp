#ifndef SYMBOLTABLE_H
#define SYMBOLTABLE_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define TYPE_INT 1
#define TYPE_CHAR 2

// Estrutura para cada entrada na tabela de símbolos
typedef struct symbol_entry {
    char* name;                     // Nome do identificador (lexema)
    int entry_type;                 // 1: variável, 2: função, 3: parâmetro
    int data_type;                  // Tipo de dado (1: int, 2: car)
    int position;                   // Posição na lista de declaração
    int param_count;                // Número de parâmetros (para funções)
    struct symbol_entry* func_ref;  // Referência para função (para parâmetros)
    struct symbol_entry* next;      // Próximo na lista encadeada
} SymbolEntry;

// Estrutura para cada tabela de símbolos (escopo)
typedef struct symbol_table {
    SymbolEntry* first;             // Primeiro símbolo na tabela
    struct symbol_table* next;      // Próxima tabela na pilha
} SymbolTable;

// Estrutura para a pilha de tabelas de símbolos
typedef struct {
    SymbolTable* top;               // Topo da pilha (escopo atual)
} SymbolTableStack;

// Operações da tabela de símbolos
void init_symbol_table_stack(SymbolTableStack* stack);
void create_new_scope(SymbolTableStack* stack);
SymbolEntry* search_symbol(SymbolTableStack* stack, char* name);
void remove_current_scope(SymbolTableStack* stack);
SymbolEntry* insert_function(SymbolTableStack* stack, char* name, int return_type, int param_count);
SymbolEntry* insert_variable(SymbolTableStack* stack, char* name, int data_type, int position);
SymbolEntry* insert_parameter(SymbolTableStack* stack, char* name, int data_type, int position, SymbolEntry* func_ref);
void destroy_symbol_table_stack(SymbolTableStack* stack);

// Funções auxiliares
void print_symbol_table(SymbolTableStack* stack);

#endif