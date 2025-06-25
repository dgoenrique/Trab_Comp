%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"
#include "symboltable.h"

// Funções e variáveis externas do Flex
extern int yylex();
extern int yylineno;
extern char* yytext;
extern FILE* yyin;

void yyerror(const char* s);

// Raiz da AST
ASTNode* arvore_abstrata = NULL;
%}


%union {
    struct ast_node* no_ast; //para passar os nós da AST nas regras
    char* str; // passar os lexemas
}

// --- TOKENS E TIPOS ---

//tokens lexicos com valores associados
%token <str> TOKEN_ID TOKEN_CONST_INT TOKEN_CONST_CHAR TOKEN_STRING

//palavras-chave e operadores
%token TOKEN_PROGRAMA TOKEN_TIPO_INT TOKEN_TIPO_CAR TOKEN_RETORNE TOKEN_LEIA
%token TOKEN_ESCREVA TOKEN_NOVALINHA TOKEN_SE TOKEN_ENTAO TOKEN_SENAO
%token TOKEN_ENQUANTO TOKEN_EXECUTE TOKEN_OU TOKEN_E TOKEN_IGUAL_IGUAL
%token TOKEN_DIFERENTE TOKEN_MENOR TOKEN_MAIOR TOKEN_MENOR_IGUAL TOKEN_MAIOR_IGUAL
%token TOKEN_MAIS TOKEN_MENOS TOKEN_MULT TOKEN_DIV TOKEN_NAO TOKEN_ABRE_PAR
%token TOKEN_FECHA_PAR TOKEN_ABRE_CHAVE TOKEN_FECHA_CHAVE TOKEN_VIRGULA
%token TOKEN_PONTO_VIRGULA TOKEN_IGUAL

//declaracao de tipos de retorno das regras 
%type <no_ast> Programa DeclFuncVar DeclProg Bloco ListaDeclVar Tipo
%type <no_ast> ListaComando Comando Expr OrExpr AndExpr EqExpr DesigExpr
%type <no_ast> AddExpr MulExpr UnExpr PrimExpr ListExpr DeclVar

// --- PRECEDÊNCIA E ASSOCIATIVIDADE ---
//para as precedencias e associatividade dos operadores
%right TOKEN_IGUAL
%left TOKEN_OU
%left TOKEN_E
%left TOKEN_IGUAL_IGUAL TOKEN_DIFERENTE
%left TOKEN_MENOR TOKEN_MAIOR TOKEN_MENOR_IGUAL TOKEN_MAIOR_IGUAL
%left TOKEN_MAIS TOKEN_MENOS
%left TOKEN_MULT TOKEN_DIV
%right TOKEN_NAO UMINUS

%start Programa

%%

/* --- REGRAS DA GRAMÁTICA COM AÇÕES SEMÂNTICAS --- */

Programa: DeclFuncVar DeclProg
        {
            $$ = $2; //rais da AST é o bloco principal
            arvore_abstrata = $$; //armazena na variável global
        }
        ;

DeclFuncVar: /* vazio */ { $$ = NULL; };

//bloco do principal do programa
DeclProg: TOKEN_PROGRAMA Bloco
        {
            $$ = $2;
        }
        ;

// não tratar múltiplas declarações na mesma linha (ex: int a, b;)
DeclVar: /* vazio */ { $$ = NULL; };

Bloco: TOKEN_ABRE_CHAVE ListaDeclVar ListaComando TOKEN_FECHA_CHAVE
     {
        //AST_BLOCO com declarações (p1) e comandos (p2)
         $$ = ast_criar_no(AST_BLOCO, NULL, yylineno, $2, $3, NULL, NULL);
     }
     ;


// constrói ativamente a lista de declarações.
ListaDeclVar: Tipo TOKEN_ID DeclVar TOKEN_PONTO_VIRGULA ListaDeclVar
            {
                //Cria um nó para o tipo (int ou car).
                ASTNode* tipoNode = $1;

                //Cria um nó para o identificador da variável.
                ASTNode* idNode = ast_criar_no(AST_ID, $2, yylineno, NULL, NULL, NULL, NULL);

                // Cria o nó de declaração (AST_DECL_VAR).
                ASTNode* declNode = ast_criar_no(AST_DECL_VAR, NULL, yylineno, tipoNode, idNode, NULL, NULL);

                //Cria um nó de lista para encadear esta declaração com as próximas.
                $$ = ast_criar_no(AST_LISTA_COMANDOS, NULL, yylineno, declNode, $5, NULL, NULL);
                
                free($2); // Libera a string copiada pelo strdup no lexer.
            }
            | /* vazio */
            {
                $$ = NULL; 
            }
            ;

Tipo: TOKEN_TIPO_INT { $$ = ast_criar_no(AST_TIPO, "int", yylineno, NULL, NULL, NULL, NULL); }
    | TOKEN_TIPO_CAR { $$ = ast_criar_no(AST_TIPO, "car", yylineno, NULL, NULL, NULL, NULL); }
    ;

ListaComando: Comando ListaComando
            {
                if ($1 != NULL) { // Ignora comandos vazios (só ponto-e-vírgula)
                    $$ = ast_criar_no(AST_LISTA_COMANDOS, NULL, $1->linha, $1, $2, NULL, NULL);
                } else {
                    $$ = $2; // Se o comando for nulo, apenas repassa o resto da lista.
                }
            }
            | /* vazio */
            {
                $$ = NULL;
            }
            ;

// --  COMANDOS --
Comando: Expr TOKEN_PONTO_VIRGULA { $$ = $1; }
       | TOKEN_SE TOKEN_ABRE_PAR Expr TOKEN_FECHA_PAR TOKEN_ENTAO Comando { $$ = ast_criar_no(AST_SE, NULL, yylineno, $3, $6, NULL, NULL); }
       | TOKEN_SE TOKEN_ABRE_PAR Expr TOKEN_FECHA_PAR TOKEN_ENTAO Comando TOKEN_SENAO Comando { $$ = ast_criar_no(AST_SE, NULL, yylineno, $3, $6, $8, NULL); }
       | TOKEN_ENQUANTO TOKEN_ABRE_PAR Expr TOKEN_FECHA_PAR TOKEN_EXECUTE Comando { $$ = ast_criar_no(AST_ENQUANTO, NULL, yylineno, $3, $6, NULL, NULL); }
       | TOKEN_RETORNE Expr TOKEN_PONTO_VIRGULA { $$ = ast_criar_no(AST_RETORNE, NULL, yylineno, $2, NULL, NULL, NULL); }
       | TOKEN_LEIA TOKEN_ID TOKEN_PONTO_VIRGULA { ASTNode* id = ast_criar_no(AST_ID, $2, yylineno, NULL, NULL, NULL, NULL); $$ = ast_criar_no(AST_LEIA, NULL, yylineno, id, NULL, NULL, NULL); free($2); }
       | TOKEN_ESCREVA Expr TOKEN_PONTO_VIRGULA { $$ = ast_criar_no(AST_ESCREVA, NULL, yylineno, $2, NULL, NULL, NULL); }
       | TOKEN_ESCREVA TOKEN_STRING TOKEN_PONTO_VIRGULA { ASTNode* str = ast_criar_no(AST_STRING, $2, yylineno, NULL, NULL, NULL, NULL); $$ = ast_criar_no(AST_ESCREVA, NULL, yylineno, str, NULL, NULL, NULL); free($2); }
       | TOKEN_NOVALINHA TOKEN_PONTO_VIRGULA { $$ = ast_criar_no(AST_NOVALINHA, NULL, yylineno, NULL, NULL, NULL, NULL); }
       | Bloco { $$ = $1; }
       | TOKEN_PONTO_VIRGULA { $$ = NULL; }
       ;


// -- EXPRESSOES: CONSTRUÇÃO POR PRECEDÊNCIA --

//atribuição
Expr: TOKEN_ID TOKEN_IGUAL Expr { ASTNode* id = ast_criar_no(AST_ID, $1, yylineno, NULL, NULL, NULL, NULL); $$ = ast_criar_no(AST_ATRIBUICAO, NULL, yylineno, id, $3, NULL, NULL); free($1); }
    | OrExpr { $$ = $1; }
    ;

//operadores
OrExpr: OrExpr TOKEN_OU AndExpr { $$ = ast_criar_no(AST_OU, NULL, yylineno, $1, $3, NULL, NULL); } | AndExpr { $$ = $1; } ;
AndExpr: AndExpr TOKEN_E EqExpr { $$ = ast_criar_no(AST_E, NULL, yylineno, $1, $3, NULL, NULL); } | EqExpr { $$ = $1; } ;
EqExpr: EqExpr TOKEN_IGUAL_IGUAL DesigExpr { $$ = ast_criar_no(AST_IGUAL_IGUAL, NULL, yylineno, $1, $3, NULL, NULL); } | EqExpr TOKEN_DIFERENTE DesigExpr { $$ = ast_criar_no(AST_DIFERENTE, NULL, yylineno, $1, $3, NULL, NULL); } | DesigExpr { $$ = $1; } ;
DesigExpr: DesigExpr TOKEN_MENOR AddExpr { $$ = ast_criar_no(AST_MENOR, NULL, yylineno, $1, $3, NULL, NULL); } | DesigExpr TOKEN_MAIOR AddExpr { $$ = ast_criar_no(AST_MAIOR, NULL, yylineno, $1, $3, NULL, NULL); } | DesigExpr TOKEN_MAIOR_IGUAL AddExpr { $$ = ast_criar_no(AST_MAIOR_IGUAL, NULL, yylineno, $1, $3, NULL, NULL); } | DesigExpr TOKEN_MENOR_IGUAL AddExpr { $$ = ast_criar_no(AST_MENOR_IGUAL, NULL, yylineno, $1, $3, NULL, NULL); } | AddExpr { $$ = $1; } ;
AddExpr: AddExpr TOKEN_MAIS MulExpr { $$ = ast_criar_no(AST_SOMA, NULL, yylineno, $1, $3, NULL, NULL); } | AddExpr TOKEN_MENOS MulExpr { $$ = ast_criar_no(AST_SUB, NULL, yylineno, $1, $3, NULL, NULL); } | MulExpr { $$ = $1; } ;
MulExpr: MulExpr TOKEN_MULT UnExpr { $$ = ast_criar_no(AST_MULT, NULL, yylineno, $1, $3, NULL, NULL); } | MulExpr TOKEN_DIV UnExpr { $$ = ast_criar_no(AST_DIV, NULL, yylineno, $1, $3, NULL, NULL); } | UnExpr { $$ = $1; } ;
UnExpr: TOKEN_MENOS PrimExpr %prec UMINUS { $$ = ast_criar_no(AST_MENOS_UNARIO, NULL, yylineno, $2, NULL, NULL, NULL); } | TOKEN_NAO PrimExpr { $$ = ast_criar_no(AST_NAO, NULL, yylineno, $2, NULL, NULL, NULL); } | PrimExpr { $$ = $1; } ;


//primários e chamadas de função
PrimExpr: TOKEN_ID TOKEN_ABRE_PAR ListExpr TOKEN_FECHA_PAR { ASTNode* id = ast_criar_no(AST_ID, $1, yylineno, NULL, NULL, NULL, NULL); $$ = ast_criar_no(AST_CHAMADA_FUNCAO, NULL, yylineno, id, $3, NULL, NULL); free($1); }
        | TOKEN_ID TOKEN_ABRE_PAR TOKEN_FECHA_PAR { ASTNode* id = ast_criar_no(AST_ID, $1, yylineno, NULL, NULL, NULL, NULL); $$ = ast_criar_no(AST_CHAMADA_FUNCAO, NULL, yylineno, id, NULL, NULL, NULL); free($1); }
        | TOKEN_ID { $$ = ast_criar_no(AST_ID, $1, yylineno, NULL, NULL, NULL, NULL); free($1); }
        | TOKEN_CONST_INT { $$ = ast_criar_no(AST_CONST_INT, $1, yylineno, NULL, NULL, NULL, NULL); free($1); }
        | TOKEN_CONST_CHAR { $$ = ast_criar_no(AST_CONST_CHAR, $1, yylineno, NULL, NULL, NULL, NULL); free($1); }
        | TOKEN_ABRE_PAR Expr TOKEN_FECHA_PAR { $$ = $2; }
        ;

//lista de argumentos
ListExpr: ListExpr TOKEN_VIRGULA Expr { $$ = ast_criar_no(AST_LISTA_EXPR, NULL, yylineno, $1, $3, NULL, NULL); }
        | Expr { $$ = ast_criar_no(AST_LISTA_EXPR, NULL, yylineno, $1, NULL, NULL, NULL); }
        ;
%%

//para erros
void yyerror(const char* s) {
    printf("ERRO SINTÁTICO: %s na linha %d\n", s, yylineno);
}