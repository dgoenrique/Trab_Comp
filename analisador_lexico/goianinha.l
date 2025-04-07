%{
#include <stdio.h>
#include <string.h>

// Códigos dos tokens
#define TOKEN_PROGRAMA 1
#define TOKEN_TIPO_INT 2
#define TOKEN_TIPO_CAR 3
#define TOKEN_RETORNE 4
#define TOKEN_LEIA 5
#define TOKEN_ESCREVA 6
#define TOKEN_NOVALINHA 7
#define TOKEN_SE 8
#define TOKEN_ENTAO 9
#define TOKEN_SENAO 10
#define TOKEN_ENQUANTO 11
#define TOKEN_EXECUTE 12
#define TOKEN_OU 13
#define TOKEN_E 14
#define TOKEN_IGUAL_IGUAL 15
#define TOKEN_DIFERENTE 16
#define TOKEN_MENOR 17
#define TOKEN_MAIOR 18
#define TOKEN_MENOR_IGUAL 19
#define TOKEN_MAIOR_IGUAL 20
#define TOKEN_MAIS 21
#define TOKEN_MENOS 22
#define TOKEN_MULT 23
#define TOKEN_DIV 24
#define TOKEN_NAO 25
#define TOKEN_ABRE_PAR 26
#define TOKEN_FECHA_PAR 27
#define TOKEN_ABRE_CHAVE 28
#define TOKEN_FECHA_CHAVE 29
#define TOKEN_VIRGULA 30
#define TOKEN_PONTO_VIRGULA 31
#define TOKEN_IGUAL 32
#define TOKEN_ID 33
#define TOKEN_CONST_INT 34
#define TOKEN_CONST_CHAR 35
#define TOKEN_STRING 36

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