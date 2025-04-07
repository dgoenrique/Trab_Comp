#include "symboltable.h"

// Inicializar a pilha de tabelas de símbolos
void init_symbol_table_stack(SymbolTableStack* stack) {
    stack->top = NULL;
}

// Criar um novo escopo (empilhar nova tabela)
void create_new_scope(SymbolTableStack* stack) {
    SymbolTable* new_table = (SymbolTable*)malloc(sizeof(SymbolTable));
    if (new_table == NULL) {
        fprintf(stderr, "Erro: Não foi possível alocar memória para nova tabela de símbolos\n");
        exit(1);
    }
    
    new_table->first = NULL;
    new_table->next = stack->top;
    stack->top = new_table;
}

// Buscar um símbolo na pilha de tabelas
SymbolEntry* search_symbol(SymbolTableStack* stack, char* name) {
    if (stack->top == NULL) {
        return NULL;
    }
    
    // Pesquisar em cada tabela da pilha, do topo para a base
    SymbolTable* current_table = stack->top;
    while (current_table != NULL) {
        SymbolEntry* current_entry = current_table->first;
        
        // Procurar na tabela atual
        while (current_entry != NULL) {
            if (strcmp(current_entry->name, name) == 0) {
                return current_entry;  // Símbolo encontrado
            }
            current_entry = current_entry->next;
        }
        
        // Não encontrado na tabela atual, descer para a próxima
        current_table = current_table->next;
    }
    
    return NULL;  // Símbolo não encontrado em nenhuma tabela
}

// Remover o escopo atual
void remove_current_scope(SymbolTableStack* stack) {
    if (stack->top == NULL) {
        return;  // Pilha vazia
    }
    
    SymbolTable* table_to_remove = stack->top;
    stack->top = stack->top->next;
    
    // Liberar memória de todas as entradas na tabela
    SymbolEntry* current = table_to_remove->first;
    while (current != NULL) {
        SymbolEntry* to_free = current;
        current = current->next;
        
        free(to_free->name);
        free(to_free);
    }
    
    free(table_to_remove);
}

// Inserir um nome de função na tabela atual
SymbolEntry* insert_function(SymbolTableStack* stack, char* name, int return_type, int param_count) {
    if (stack->top == NULL) {
        fprintf(stderr, "Erro: Tentativa de inserir função em pilha de tabelas vazia\n");
        return NULL;
    }
    
    // Verificar se já existe na tabela atual
    SymbolEntry* current = stack->top->first;
    while (current != NULL) {
        if (strcmp(current->name, name) == 0) {
            return current;  // Já existe, retornar referência
        }
        current = current->next;
    }
    
    // Criar nova entrada
    SymbolEntry* new_entry = (SymbolEntry*)malloc(sizeof(SymbolEntry));
    if (new_entry == NULL) {
        fprintf(stderr, "Erro: Não foi possível alocar memória para nova entrada na tabela\n");
        exit(1);
    }
    
    new_entry->name = strdup(name);
    new_entry->entry_type = 2;  // 2 = função
    new_entry->data_type = return_type;
    new_entry->position = 0;
    new_entry->param_count = param_count;
    new_entry->func_ref = NULL;
    
    // Inserir no início da lista
    new_entry->next = stack->top->first;
    stack->top->first = new_entry;
    
    return new_entry;
}

// Inserir um nome de variável na tabela atual
SymbolEntry* insert_variable(SymbolTableStack* stack, char* name, int data_type, int position) {
    if (stack->top == NULL) {
        fprintf(stderr, "Erro: Tentativa de inserir variável em pilha de tabelas vazia\n");
        return NULL;
    }
    
    // Verificar se já existe na tabela atual
    SymbolEntry* current = stack->top->first;
    while (current != NULL) {
        if (strcmp(current->name, name) == 0) {
            return current;  // Já existe, retornar referência
        }
        current = current->next;
    }
    
    // Criar nova entrada
    SymbolEntry* new_entry = (SymbolEntry*)malloc(sizeof(SymbolEntry));
    if (new_entry == NULL) {
        fprintf(stderr, "Erro: Não foi possível alocar memória para nova entrada na tabela\n");
        exit(1);
    }
    
    new_entry->name = strdup(name);
    new_entry->entry_type = 1;  // 1 = variável
    new_entry->data_type = data_type;
    new_entry->position = position;
    new_entry->param_count = 0;
    new_entry->func_ref = NULL;
    
    // Inserir no início da lista
    new_entry->next = stack->top->first;
    stack->top->first = new_entry;
    
    return new_entry;
}

// Inserir um nome de parâmetro na tabela atual
SymbolEntry* insert_parameter(SymbolTableStack* stack, char* name, int data_type, int position, SymbolEntry* func_ref) {
    if (stack->top == NULL) {
        fprintf(stderr, "Erro: Tentativa de inserir parâmetro em pilha de tabelas vazia\n");
        return NULL;
    }
    
    // Verificar se já existe na tabela atual
    SymbolEntry* current = stack->top->first;
    while (current != NULL) {
        if (strcmp(current->name, name) == 0) {
            return current;  // Já existe, retornar referência
        }
        current = current->next;
    }
    
    // Criar nova entrada
    SymbolEntry* new_entry = (SymbolEntry*)malloc(sizeof(SymbolEntry));
    if (new_entry == NULL) {
        fprintf(stderr, "Erro: Não foi possível alocar memória para nova entrada na tabela\n");
        exit(1);
    }
    
    new_entry->name = strdup(name);
    new_entry->entry_type = 3;  // 3 = parâmetro
    new_entry->data_type = data_type;
    new_entry->position = position;
    new_entry->param_count = 0;
    new_entry->func_ref = func_ref;
    
    // Inserir no início da lista
    new_entry->next = stack->top->first;
    stack->top->first = new_entry;
    
    return new_entry;
}

// Destruir a pilha de tabelas de símbolos
void destroy_symbol_table_stack(SymbolTableStack* stack) {
    while (stack->top != NULL) {
        remove_current_scope(stack);
    }
}

// Função auxiliar para imprimir a tabela de símbolos (para depuração)
void print_symbol_table(SymbolTableStack* stack) {
    if (stack->top == NULL) {
        printf("Pilha de tabelas de símbolos vazia.\n");
        return;
    }
    
    int scope_level = 0;
    SymbolTable* current_table = stack->top;
    
    while (current_table != NULL) {
        printf("Escopo %d:\n", scope_level);
        
        if (current_table->first == NULL) {
            printf("  (vazio)\n");
        } else {
            SymbolEntry* current_entry = current_table->first;
            
            while (current_entry != NULL) {
                printf("  Nome: %s, Tipo: ", current_entry->name);
                
                switch (current_entry->entry_type) {
                    case 1:
                        printf("Variável");
                        break;
                    case 2:
                        printf("Função (params: %d)", current_entry->param_count);
                        break;
                    case 3:
                        printf("Parâmetro (func: %s)", 
                              current_entry->func_ref ? current_entry->func_ref->name : "desconhecido");
                        break;
                    default:
                        printf("Desconhecido");
                }
                
                printf(", DataType: %s, Pos: %d\n",
                      current_entry->data_type == TYPE_INT ? "int" : "car",
                      current_entry->position);
                
                current_entry = current_entry->next;
            }
        }
        
        current_table = current_table->next;
        scope_level++;
        printf("\n");
    }
}