%{
#include <stdlib.h>
#include <stdio.h>

extern int yylex(void);
extern int yyerror(const char *msg);
extern int yylineno;
%}

%define parse.error verbose

// --- Mots clés ---
%token TOK_IF
%token TOK_THEN
%token TOK_ELSE
%token TOK_ELSEIF
%token TOK_END
%token TOK_ENDIF
%token TOK_WHILE
%token TOK_DO
%token TOK_CONTINUE
%token TOK_BREAK
%token TOK_ENDWHILE
%token TOK_READ
%token TOK_PRINT
%token TOK_TRUE
%token TOK_FALSE
%token TOK_NOT
%token TOK_AND
%token TOK_OR

// --- Ponctuation & Opérateurs Arithmétiques ---
%token TOK_SEMI_COLON
%token TOK_AFFECTATION   /* Correspond à := */
%token TOK_ADD
%token TOK_SUB
%token TOK_MUL
%token TOK_DIV
%token TOK_BRACKET_L
%token TOK_BRACKET_R

// --- Opérateurs de Comparaison ---
%token TOK_GE            /* >= */
%token TOK_LE            /* <= */
%token TOK_GT            /* >  */
%token TOK_LT            /* <  */
%token TOK_EQ            /* =  */
%token TOK_NE            /* #  */

%token TOK_IDENTIFIER
%token TOK_NUMBER

%%

program: code;

code: code instruction | ;

instruction: affectation ;

affectation:
    identifier TOK_AFFECTATION expression TOK_SEMI_COLON;

expression:
    identifier |
    number ;

identifier:
    TOK_IDENTIFIER ;

number:
    TOK_NUMBER ;

%%

/*
* file: facile.y
* version: 0.8.0
*/

int yyerror(const char *msg) {
    fprintf(stderr, "Line %d: %s\n", yylineno, msg);
}
int main(int argc, char *argv[]) {
    yyparse();
    return EXIT_SUCCESS;
}