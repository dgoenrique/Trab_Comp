#include "symboltable.h"

int main() {
    SymbolTableStack stack;
    init_symbol_table_stack(&stack);
    
    printf("Teste da Tabela de Símbolos para Goianinha\n");
    printf("==========================================\n\n");
    
    // Criar escopo global
    create_new_scope(&stack);
    printf("Escopo global criado.\n");
    
    // Inserir algumas funções e variáveis no escopo global
    insert_function(&stack, "fatorial", TYPE_INT, 1);
    insert_variable(&stack, "x", TYPE_INT, 1);
    insert_variable(&stack, "y", TYPE_INT, 2);
    
    printf("\nTeste 1: Tabela após inserções no escopo global:\n");
    print_symbol_table(&stack);
    
    // Verificar busca
    SymbolEntry* found = search_symbol(&stack, "fatorial");
    printf("\nTeste 2: Busca por 'fatorial': %s\n", found ? "Encontrado" : "Não encontrado");
    
    SymbolEntry* not_found = search_symbol(&stack, "z");
    printf("Teste 3: Busca por 'z': %s\n", not_found ? "Encontrado" : "Não encontrado");
    
    // Criar escopo para uma função
    create_new_scope(&stack);
    printf("\nNovo escopo criado (para função).\n");
    
    // Inserir parâmetro
    insert_parameter(&stack, "n", TYPE_INT, 1, found);
    
    // Inserir variáveis locais
    insert_variable(&stack, "z", TYPE_INT, 1);
    
    printf("\nTeste 4: Tabela após inserções no escopo da função:\n");
    print_symbol_table(&stack);
    
    // Verificar busca em múltiplos escopos
    SymbolEntry* found_local = search_symbol(&stack, "z");
    printf("\nTeste 5: Busca por 'z' após declaração local: %s\n", 
          found_local ? "Encontrado" : "Não encontrado");
    
    SymbolEntry* found_in_outer = search_symbol(&stack, "x");
    printf("Teste 6: Busca por 'x' do escopo externo: %s\n", 
          found_in_outer ? "Encontrado" : "Não encontrado");
    
    // Criar mais um escopo aninhado
    create_new_scope(&stack);
    printf("\nNovo escopo aninhado criado.\n");
    
    // Sobrepor variável x
    insert_variable(&stack, "x", TYPE_INT, 1);
    insert_variable(&stack, "temp", TYPE_INT, 2);
    
    printf("\nTeste 7: Tabela após inserções no escopo aninhado:\n");
    print_symbol_table(&stack);
    
    // Remover escopo aninhado
    remove_current_scope(&stack);
    printf("\nEscopo aninhado removido.\n");
    
    printf("\nTeste 8: Tabela após remoção do escopo aninhado:\n");
    print_symbol_table(&stack);
    
    // Destruir a pilha completa
    destroy_symbol_table_stack(&stack);
    printf("\nPilha de tabelas destruída.\n");
    
    return 0;
}