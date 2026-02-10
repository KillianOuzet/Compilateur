%{
#include <assert.h>
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
%}

%%

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

[ab]*a[ab]*b[ab]*b[ab]*a {
    assert(printf("'abba' found")); 
    return yytext[0];
}

%%
/*
* file: facile.lex
* version: 0.2.0
*/