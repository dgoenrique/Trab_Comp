%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylex();
extern int yylineno;
extern char* yytext;
extern FILE* yyin;

void yyerror(const char* s);
%}

/* Declaração de tokens */
%token TOKEN_PROGRAMA
%token TOKEN_TIPO_INT TOKEN_TIPO_CAR
%token TOKEN_RETORNE TOKEN_LEIA TOKEN_ESCREVA TOKEN_NOVALINHA
%token TOKEN_SE TOKEN_ENTAO TOKEN_SENAO TOKEN_ENQUANTO TOKEN_EXECUTE
%token TOKEN_OU TOKEN_E
%token TOKEN_IGUAL_IGUAL TOKEN_DIFERENTE
%token TOKEN_MENOR TOKEN_MAIOR TOKEN_MENOR_IGUAL TOKEN_MAIOR_IGUAL
%token TOKEN_MAIS TOKEN_MENOS TOKEN_MULT TOKEN_DIV TOKEN_NAO
%token TOKEN_ABRE_PAR TOKEN_FECHA_PAR TOKEN_ABRE_CHAVE TOKEN_FECHA_CHAVE
%token TOKEN_VIRGULA TOKEN_PONTO_VIRGULA TOKEN_IGUAL
%token TOKEN_ID TOKEN_CONST_INT TOKEN_CONST_CHAR TOKEN_STRING

/* Precedência e associatividade dos operadores (do menor para o maior) */
%right TOKEN_IGUAL
%left TOKEN_OU
%left TOKEN_E
%left TOKEN_IGUAL_IGUAL TOKEN_DIFERENTE
%left TOKEN_MENOR TOKEN_MAIOR TOKEN_MENOR_IGUAL TOKEN_MAIOR_IGUAL
%left TOKEN_MAIS TOKEN_MENOS
%left TOKEN_MULT TOKEN_DIV
%right TOKEN_NAO UMINUS

/* Símbolo inicial da gramática */
%start Programa

%%

/* Regras gramaticais seguindo exatamente a especificação */
Programa: DeclFuncVar DeclProg
        ;

DeclFuncVar: Tipo TOKEN_ID DeclVar TOKEN_PONTO_VIRGULA DeclFuncVar
           | Tipo TOKEN_ID DeclFunc DeclFuncVar
           | /* vazio */
           ;

DeclProg: TOKEN_PROGRAMA Bloco
        ;

DeclVar: TOKEN_VIRGULA TOKEN_ID DeclVar
       | /* vazio */
       ;

DeclFunc: TOKEN_ABRE_PAR ListaParametros TOKEN_FECHA_PAR Bloco
        ;

ListaParametros: /* vazio */
               | ListaParametrosCont
               ;

ListaParametrosCont: Tipo TOKEN_ID
                    | Tipo TOKEN_ID TOKEN_VIRGULA ListaParametrosCont
                    ;

Bloco: TOKEN_ABRE_CHAVE ListaDeclVar ListaComando TOKEN_FECHA_CHAVE
     ;

ListaDeclVar: /* vazio */
            | Tipo TOKEN_ID DeclVar TOKEN_PONTO_VIRGULA ListaDeclVar
            ;

Tipo: TOKEN_TIPO_INT
    | TOKEN_TIPO_CAR
    ;

ListaComando: Comando
            | Comando ListaComando
            ;

Comando: TOKEN_PONTO_VIRGULA
       | Expr TOKEN_PONTO_VIRGULA
       | TOKEN_RETORNE Expr TOKEN_PONTO_VIRGULA
       | TOKEN_LEIA TOKEN_ID TOKEN_PONTO_VIRGULA
       | TOKEN_ESCREVA Expr TOKEN_PONTO_VIRGULA
       | TOKEN_ESCREVA TOKEN_STRING TOKEN_PONTO_VIRGULA
       | TOKEN_NOVALINHA TOKEN_PONTO_VIRGULA
       | TOKEN_SE TOKEN_ABRE_PAR Expr TOKEN_FECHA_PAR TOKEN_ENTAO Comando
       | TOKEN_SE TOKEN_ABRE_PAR Expr TOKEN_FECHA_PAR TOKEN_ENTAO Comando TOKEN_SENAO Comando
       | TOKEN_ENQUANTO TOKEN_ABRE_PAR Expr TOKEN_FECHA_PAR TOKEN_EXECUTE Comando
       | Bloco
       ;

Expr: OrExpr
    | TOKEN_ID TOKEN_IGUAL Expr
    ;

OrExpr: OrExpr TOKEN_OU AndExpr
      | AndExpr
      ;

AndExpr: AndExpr TOKEN_E EqExpr
       | EqExpr
       ;

EqExpr: EqExpr TOKEN_IGUAL_IGUAL DesigExpr
      | EqExpr TOKEN_DIFERENTE DesigExpr
      | DesigExpr
      ;

DesigExpr: DesigExpr TOKEN_MENOR AddExpr
         | DesigExpr TOKEN_MAIOR AddExpr
         | DesigExpr TOKEN_MAIOR_IGUAL AddExpr
         | DesigExpr TOKEN_MENOR_IGUAL AddExpr
         | AddExpr
         ;

AddExpr: AddExpr TOKEN_MAIS MulExpr
       | AddExpr TOKEN_MENOS MulExpr
       | MulExpr
       ;

MulExpr: MulExpr TOKEN_MULT UnExpr
       | MulExpr TOKEN_DIV UnExpr
       | UnExpr
       ;

UnExpr: TOKEN_MENOS PrimExpr %prec UMINUS
      | TOKEN_NAO PrimExpr
      | PrimExpr
      ;

PrimExpr: TOKEN_ID TOKEN_ABRE_PAR ListExpr TOKEN_FECHA_PAR
        | TOKEN_ID TOKEN_ABRE_PAR TOKEN_FECHA_PAR
        | TOKEN_ID
        | TOKEN_CONST_CHAR
        | TOKEN_CONST_INT
        | TOKEN_ABRE_PAR Expr TOKEN_FECHA_PAR
        ;

ListExpr: Expr
        | ListExpr TOKEN_VIRGULA Expr
        ;

%%

/* Função de tratamento de erro sintático */
void yyerror(const char* s) {
    printf("ERRO: %s na linha %d\n", s, yylineno);
}