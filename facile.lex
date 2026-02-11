%{
#include <assert.h>

#include "facile.y.h"
%}

%option yylineno

%%

    /* --- Mots Clés --- */

if {
    assert(printf("'if' found"));
    return TOK_IF;
}

then {
    assert(printf("'then' found"));
    return TOK_THEN;
}

else {
    assert(printf("'else' found"));
    return TOK_ELSE;
}

elseif {
    assert(printf("'elseif' found"));
    return TOK_ELSEIF;
}

end {
    assert(printf("'end' found"));
    return TOK_END;
}

endif {
    assert(printf("'endif' found"));
    return TOK_ENDIF;
}

while {
    assert(printf("'while' found"));
    return TOK_WHILE;
}

do {
    assert(printf("'do' found"));
    return TOK_DO;
}

continue {
    assert(printf("'continue' found"));
    return TOK_CONTINUE;
}

break {
    assert(printf("'break' found"));
    return TOK_BREAK;
}

endwhile {
    assert(printf("'endwhile' found"));
    return TOK_ENDWHILE;
}

read {
    assert(printf("'read' found"));
    return TOK_READ;
}

print {
    assert(printf("'print' found"));
    return TOK_PRINT;
}

true {
    assert(printf("'true' found"));
    return TOK_TRUE;
}

false {
    assert(printf("'false' found"));
    return TOK_FALSE;
}

not {
    assert(printf("'not' found"));
    return TOK_NOT;
}

and {
    assert(printf("'and' found"));
    return TOK_AND;
}

or {
    assert(printf("'or' found"));
    return TOK_OR;
}

    /* --- Ponctuation & Arithmétique --- */

";" {
    assert(printf("';' found"));
    return TOK_SEMI_COLON;
}

":=" {
    assert(printf("':=' found"));
    return TOK_AFFECTATION;
}

"+" {
    assert(printf("'+' found"));
    return TOK_ADD;
}

"-" {
    assert(printf("'-' found"));
    return TOK_SUB;
}

"*" {
    assert(printf("'*' found"));
    return TOK_MUL;
}

"/" {
    assert(printf("'/' found"));
    return TOK_DIV;
}

"(" {
    assert(printf("'(' found"));
    return TOK_BRACKET_L;
}

")" {
    assert(printf("')' found"));
    return TOK_BRACKET_R;
}

    /* --- Comparaisons --- */

">=" {
    assert(printf("'>=' found"));
    return TOK_GE;
}

"<=" {
    assert(printf("'<=' found"));
    return TOK_LE;
}

">" {
    assert(printf("'>' found"));
    return TOK_GT;
}

"<" {
    assert(printf("'<' found"));
    return TOK_LT;
}

"=" {
    assert(printf("'=' found"));
    return TOK_EQ;
}

"#" {
    assert(printf("'#' found"));
    return TOK_NE;
}

[a-zA-Z][a-zA-Z0-9_]* {
    assert(printf("identifier '%s(%d)' found", yytext, yyleng));
    return TOK_IDENTIFIER;
}

0|[1-9][0-9]* {
    assert(printf("number '%s(%d)' found", yytext, yyleng));
    return TOK_NUMBER;
}

[ \t\n] ;

. {
    return yytext[0];
}

%%
/*
* file: facile.lex
* version: 0.8.0
*/