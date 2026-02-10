%{
#include <stdlib.h>
#include <stdio.h>

extern int yylex(void);
extern int yyerror(const char *msg);
%}

%token TOK_NUMBER
%token TOK_IDENTIFIER
%token TOK_AFFECTATION
%token TOK_SEMI_COLON
%token TOK_IF
%token TOK_THEN
%token TOK_ADD
%token TOK_SUB
%token TOK_MUL
%token TOK_DIV

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
* version: 0.7.0
*/

int yyerror(const char *msg) {
    fprintf(stderr, "%s\n", msg);
}
int main(int argc, char *argv[]) {
    yyparse();
    return EXIT_SUCCESS;
}