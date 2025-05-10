%{
#include <stdio.h>
#include <string.h>
#include "y.tab.h"  /* Incluir os cabeçalhos gerados pelo Bison */

// Flag para controlar se estamos no meio de um comentário
int comentario_aberto = 0;
int linha_comentario_inicio = 0;

// Função para reportar erro léxico
void erro_lexico(char* msg) {
    printf("ERRO: %s %d\n", msg, yylineno);
    exit(1);
}

%}

%option noyywrap
%option yylineno
%option noinput
%option nounput

/* Define estados exclusivos */
%x COMMENT

/* Definições */
DIGITO      [0-9]
LETRA       [a-zA-Z]
ID          ({LETRA}|_)({LETRA}|{DIGITO}|_)*
CONST_INT   {DIGITO}+
ESPACO      [ \t\r]+
NOVA_LINHA  \n

%%

 /* Palavras reservadas */
"programa"   { return TOKEN_PROGRAMA; }
"int"        { return TOKEN_TIPO_INT; }
"car"        { return TOKEN_TIPO_CAR; }
"retorne"    { return TOKEN_RETORNE; }
"leia"       { return TOKEN_LEIA; }
"escreva"    { return TOKEN_ESCREVA; }
"novalinha"  { return TOKEN_NOVALINHA; }
"se"         { return TOKEN_SE; }
"entao"      { return TOKEN_ENTAO; }
"senao"      { return TOKEN_SENAO; }
"enquanto"   { return TOKEN_ENQUANTO; }
"execute"    { return TOKEN_EXECUTE; }
"ou"         { return TOKEN_OU; }
"e"          { return TOKEN_E; }

 /* Operadores */
"=="         { return TOKEN_IGUAL_IGUAL; }
"!="         { return TOKEN_DIFERENTE; }
"<"          { return TOKEN_MENOR; }
">"          { return TOKEN_MAIOR; }
"<="         { return TOKEN_MENOR_IGUAL; }
">="         { return TOKEN_MAIOR_IGUAL; }
"+"          { return TOKEN_MAIS; }
"-"          { return TOKEN_MENOS; }
"*"          { return TOKEN_MULT; }
"/"          { return TOKEN_DIV; }
"!"          { return TOKEN_NAO; }
"("          { return TOKEN_ABRE_PAR; }
")"          { return TOKEN_FECHA_PAR; }
"{"          { return TOKEN_ABRE_CHAVE; }
"}"          { return TOKEN_FECHA_CHAVE; }
","          { return TOKEN_VIRGULA; }
";"          { return TOKEN_PONTO_VIRGULA; }
"="          { return TOKEN_IGUAL; }

 /* Identificadores e constantes */
{ID}         { return TOKEN_ID; }
{CONST_INT}  { return TOKEN_CONST_INT; }
\'.\' { return TOKEN_CONST_CHAR; }

 /* Strings (cadeias de caracteres) */
\"[^\"\n]*\" { return TOKEN_STRING; }
\"[^\"\n]*\n { erro_lexico("CADEIA DE CARACTERES OCUPA MAIS DE UMA LINHA"); }
\"[^\"\n]*   { erro_lexico("CADEIA DE CARACTERES OCUPA MAIS DE UMA LINHA"); }

 /* Comentários */
"/*"         { 
                comentario_aberto = 1; 
                linha_comentario_inicio = yylineno;
                BEGIN(COMMENT); 
             }

<COMMENT>"*/" { 
                comentario_aberto = 0; 
                BEGIN(INITIAL); 
             }
<COMMENT>\n  { /* ignorar quebra de linha em comentários */ }
<COMMENT>.   { /* ignorar qualquer caractere em comentários */ }
<COMMENT><<EOF>> { 
                    if (comentario_aberto) {
                        erro_lexico("COMENTARIO NAO TERMINA");
                    }
                 }

 /* Espaços em branco e quebras de linha */
{ESPACO}     { /* ignorar espaços */ }
{NOVA_LINHA} { /* ignorar quebras de linha */ }

 /* Qualquer outro caractere é inválido */
.            { erro_lexico("CARACTERE INVALIDO"); }

<<EOF>>      { 
                if (comentario_aberto) {
                    erro_lexico("COMENTARIO NAO TERMINA");
                }
                return EOF;
             }

%%