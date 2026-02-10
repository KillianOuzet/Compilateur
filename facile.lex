%{
#include <assert.h>

// --- Mots clés ---
#define TOK_IF 258
#define TOK_THEN 259
#define TOK_ELSE 260
#define TOK_ELSEIF 261
#define TOK_END 262
#define TOK_ENDIF 263
#define TOK_WHILE 264
#define TOK_DO 265
#define TOK_CONTINUE 266
#define TOK_BREAK 267
#define TOK_ENDWHILE 268
#define TOK_READ 269
#define TOK_PRINT 270
#define TOK_TRUE 271
#define TOK_FALSE 272
#define TOK_NOT 273
#define TOK_AND 274
#define TOK_OR 275

// --- Ponctuation & Opérateurs Arithmétiques ---
#define TOK_SEMI_COLON 276
#define TOK_AFFECTATION 277   /* Correspond à := */
#define TOK_ADD 278
#define TOK_SUB 279
#define TOK_MUL 280
#define TOK_DIV 281
#define TOK_BRACKET_L 282
#define TOK_BRACKET_R 283

// --- Opérateurs de Comparaison (Nouveaux) ---
#define TOK_GE 284            /* >= */
#define TOK_LE 285            /* <= */
#define TOK_GT 286            /* >  */
#define TOK_LT 287            /* <  */
#define TOK_EQ 288            /* =  */
#define TOK_NE 289            /* #  */

#define TOK_IDENTIFIER 290
#define TOK_NUMBER 291
%}

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
    assert(printf("number '%s' found", yytext));
    return TOK_NUMBER;
}

[ \t\n] ;

. {
    return yytext[0];
}

%%
/*
* file: facile.lex
* version: 0.5.0
*/