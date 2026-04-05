%{
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <glib.h>

extern int yylex(void);
extern int yyerror(const char *msg);
extern int yylineno;

GHashTable *table;
FILE *stream;
char *module_name;

void begin_code(void);
void produce_code(GNode* node);
void end_code(void);
%}

%define parse.error verbose

%union {
gulong number;
gchar *string;
GNode * node;
}

// --- Mots clés ---
%token TOK_IF "if"
%token TOK_THEN "then"
%token TOK_ELSE "else"
%token TOK_ELSEIF "else if"
%token TOK_END "end"
%token TOK_ENDIF "endif"
%token TOK_WHILE "while"
%token TOK_DO "do"
%token TOK_CONTINUE "continue"
%token TOK_BREAK "break"
%token TOK_ENDWHILE "endwhile"
%token TOK_READ "read"
%token TOK_PRINT "print"
%token TOK_TRUE "true"
%token TOK_FALSE "false"
%token TOK_NOT "not"
%token TOK_AND "and"
%token TOK_OR "or"

// --- Ponctuation & Opérateurs Arithmétiques ---
%token TOK_AFFECTATION ":="
%token TOK_SEMI_COLON ";"
%left TOK_ADD "+"
%left TOK_SUB "-"
%left TOK_MUL "*"
%left TOK_DIV "/"
%token TOK_OPEN_PARENTHESIS "("
%token TOK_CLOSE_PARENTHESIS ")"

// --- Opérateurs de Comparaison ---
%token TOK_GE  ">="
%token TOK_LE  "<="
%token TOK_LT  "<"
%token TOK_GT  ">"
%token TOK_EQ  "="
%token TOK_NE  "#"

%token<number> TOK_NUMBER "number"
%token<string> TOK_IDENTIFIER "identifier"

%type<node> code
%type<node> expression
%type<node> instruction
%type<node> identifier
%type<node> print
%type<node> read
%type<node> affectation
%type<node> number
%type<node> if_stmt
%type<node> boolean
%type<node> else_branch
%type<node> elseif_list
%type<node> while_stmt

%%

program:
    code
    {
        begin_code();
        produce_code($1);
        end_code();
        g_node_destroy($1);
    }
    ;

code:
    code instruction
    {
        $$ = g_node_new("code");
        g_node_append($$, $1);
        g_node_append($$, $2);
    }
    | /* Règle vide */
    {
        $$ = g_node_new("");
    }
    ;

instruction:
    affectation
    | print
    | read
    | if_stmt
    | while_stmt
    | TOK_BREAK
    {
        $$ = g_node_new("break");
    }
    | TOK_CONTINUE
    {
        $$ = g_node_new("continue");
    }
    ;

affectation:
    identifier TOK_AFFECTATION expression TOK_SEMI_COLON
    {
        $$ = g_node_new("affectation");
        g_node_append($$, $1);
        g_node_append($$, $3);
    }
    ;

print:
    TOK_PRINT expression TOK_SEMI_COLON
    {
        $$ = g_node_new("print");
        g_node_append($$, $2);
    }
    ;

read:
    TOK_READ identifier TOK_SEMI_COLON
    {
        $$ = g_node_new("read");
        g_node_append($$, $2);
    }
    ;

if_stmt:
    TOK_IF boolean TOK_THEN code end_token
    {
        $$ = g_node_new("if");
        g_node_append($$, $2);
        g_node_append($$, $4);
    }
    | TOK_IF boolean TOK_THEN code else_branch end_token
    {
        $$ = g_node_new("if");
        g_node_append($$, $2);
        g_node_append($$, $4);
        g_node_append($$, $5);
    }
    | TOK_IF boolean TOK_THEN code elseif_list end_token
    {
        $$ = g_node_new("if");
        g_node_append($$, $2);
        g_node_append($$, $4);
        g_node_append($$, $5);
    }
    ;

else_branch:
    TOK_ELSE code
    {
        $$ = $2;
    }
    ;

elseif_list:
    TOK_ELSEIF boolean TOK_THEN code
    {
        $$ = g_node_new("if"); // Un elseif est juste un sous-if !
        g_node_append($$, $2);
        g_node_append($$, $4);
    }
    | TOK_ELSEIF boolean TOK_THEN code else_branch
    {
        $$ = g_node_new("if");
        g_node_append($$, $2);
        g_node_append($$, $4);
        g_node_append($$, $5);
    }
    | TOK_ELSEIF boolean TOK_THEN code elseif_list
    {
        $$ = g_node_new("if");
        g_node_append($$, $2);
        g_node_append($$, $4);
        g_node_append($$, $5);
    }
    ;

end_token:
    TOK_END
    | TOK_ENDIF
    ;

while_stmt:
    TOK_WHILE boolean TOK_DO code endwhile_token
    {
        $$ = g_node_new("while");
        g_node_append($$, $2);
        g_node_append($$, $4);
    }
    ;

endwhile_token:
    TOK_END
    | TOK_ENDWHILE
    ;

expression:
    identifier
    | number
    | expression TOK_ADD expression
    {
        $$ = g_node_new("add");
        g_node_append($$, $1);
        g_node_append($$, $3);
    }
    | expression TOK_SUB expression
    {
        $$ = g_node_new("sub");
        g_node_append($$, $1);
        g_node_append($$, $3);
    }
    | expression TOK_MUL expression
    {
        $$ = g_node_new("mul");
        g_node_append($$, $1);
        g_node_append($$, $3);
    }
    | expression TOK_DIV expression
    {
        $$ = g_node_new("div");
        g_node_append($$, $1);
        g_node_append($$, $3);
    }
    | TOK_OPEN_PARENTHESIS expression TOK_CLOSE_PARENTHESIS
    {
        $$ = $2;
    }
    ;

identifier:
    TOK_IDENTIFIER
    {
        $$ = g_node_new("identifier");
        gulong value = (gulong) g_hash_table_lookup(table, $1);
        if (!value) {
            value = g_hash_table_size(table) + 1;
            g_hash_table_insert(table, strdup($1), (gpointer) value);
        }
        g_node_append_data($$, (gpointer)value);
    }
    ;

number:
    TOK_NUMBER
    {
        $$ = g_node_new("number");
        g_node_append_data($$, (gpointer)$1);
    }
    ;

boolean:
    TOK_TRUE
    { $$ = g_node_new("true"); }
    | TOK_FALSE
    { $$ = g_node_new("false"); }
    | expression TOK_EQ expression
    {
        $$ = g_node_new("eq");
        g_node_append($$, $1);
        g_node_append($$, $3);
    }
    | expression TOK_GT expression
    {
        $$ = g_node_new("gt");
        g_node_append($$, $1);
        g_node_append($$, $3);
    }
    | expression TOK_LT expression
    {
        $$ = g_node_new("lt");
        g_node_append($$, $1);
        g_node_append($$, $3);
    }
    | expression TOK_GE expression
    {
        $$ = g_node_new("ge");
        g_node_append($$, $1);
        g_node_append($$, $3);
    }
    | expression TOK_LE expression
    {
        $$ = g_node_new("le");
        g_node_append($$, $1);
        g_node_append($$, $3);
    }
    ;

%%

/*
* file: facile.y
* version: 0.8.0
*/

// Pile pour retenir l'ID de la boucle courante (pour break et continue) sinon on ne saura pas pour quelle boucle les appliquer
int loop_stack[100];
int loop_depth = 0;

void begin_code(void) {
    fprintf(stream, ".assembly %s {}\n", module_name);
    fprintf(stream, ".assembly extern mscorlib {}\n");
    fprintf(stream, ".method static void Main()\n");
    fprintf(stream, "{\n");
    fprintf(stream, " .entrypoint\n");
    fprintf(stream, " .maxstack 10\n");
    
    // Déclaration dynamique des variables locales
    guint nb_vars = g_hash_table_size(table);
    if (nb_vars > 0) {
        fprintf(stream, " .locals init (");
        for (guint i = 0; i < nb_vars; i++) {
            if (i > 0) fprintf(stream, ", ");
            fprintf(stream, "int32");
        }
        fprintf(stream, ")\n");
    }
}

void end_code(void) {
    // Pied de page du fichier assembleur CIL
    fprintf(stream, " ret\n");
    fprintf(stream, "}\n");
}

void produce_code(GNode* node) {
    if (node->data == "code") {
        produce_code(g_node_nth_child(node, 0));
        produce_code(g_node_nth_child(node, 1));
    } else if (node->data == "affectation") {
        produce_code(g_node_nth_child(node, 1));
        fprintf(stream, " stloc\t%ld\n", (long)g_node_nth_child(g_node_nth_child(node, 0), 0)->data - 1);
    } else if (node->data == "add") {
        produce_code(g_node_nth_child(node, 0));
        produce_code(g_node_nth_child(node, 1));
        fprintf(stream, " add\n");
    } else if (node->data == "sub") {
        produce_code(g_node_nth_child(node, 0));
        produce_code(g_node_nth_child(node, 1));
        fprintf(stream, " sub\n");
    } else if (node->data == "mul") {
        produce_code(g_node_nth_child(node, 0));
        produce_code(g_node_nth_child(node, 1));
        fprintf(stream, " mul\n");
    } else if (node->data == "div") {
        produce_code(g_node_nth_child(node, 0));
        produce_code(g_node_nth_child(node, 1));
        fprintf(stream, " div\n");
    } else if (node->data == "number") {
        fprintf(stream, " ldc.i4\t%ld\n", (long)g_node_nth_child(node, 0)->data);
    } else if (node->data == "identifier") {
        fprintf(stream, " ldloc\t%ld\n", (long)g_node_nth_child(node, 0)->data - 1);
    } else if (node->data == "print") {
        produce_code(g_node_nth_child(node, 0));
        fprintf(stream, " call void class [mscorlib]System.Console::WriteLine(int32)\n");
    } else if (node->data == "read") {
        fprintf(stream, " call string class [mscorlib]System.Console::ReadLine()\n");
        fprintf(stream, " call int32 int32::Parse(string)\n");
        fprintf(stream, " stloc\t%ld\n", (long)g_node_nth_child(g_node_nth_child(node, 0), 0)->data - 1);
    } else if (strcmp((char*)node->data, "if") == 0) {
        static int if_count = 0; 
        int current_if = if_count++;
        
        produce_code(g_node_nth_child(node, 0));
        fprintf(stream, " brfalse IF_FALSE_%d\n", current_if); // Si Faux, on saute à FALSE
        
        produce_code(g_node_nth_child(node, 1)); // Code si Vrai
        
        // S'il y a un ELSE ou un ELSEIF, on doit sauter par-dessus pour ne pas l'exécuter
        if (g_node_n_children(node) == 3) {
            fprintf(stream, " br IF_END_%d\n", current_if);
        }
        
        fprintf(stream, "IF_FALSE_%d:\n", current_if); // else
        
        // S'il y a un ELSE ou un ELSEIF, on génère son code
        if (g_node_n_children(node) == 3) {
            produce_code(g_node_nth_child(node, 2));
            fprintf(stream, "IF_END_%d:\n", current_if); // fin else
        }
    } else if (strcmp((char*)node->data, "while") == 0) {
        static int while_count = 0; 
        int current_while = while_count++;
        
        // On entre dans la boucle on empile son ID
        loop_stack[loop_depth] = current_while;
        loop_depth++;
        
        fprintf(stream, "WHILE_START_%d:\n", current_while);
        // Évaluation de la condition
        produce_code(g_node_nth_child(node, 0));
        // Faux on skip
        fprintf(stream, " brfalse WHILE_END_%d\n", current_while); 
        
        // Code boucle
        produce_code(g_node_nth_child(node, 1)); 
        
        // bouclage
        fprintf(stream, " br WHILE_START_%d\n", current_while);
        fprintf(stream, "WHILE_END_%d:\n", current_while); 
        
        // On sort de la boucle on dépile son ID
        loop_depth--;

    } else if (strcmp((char*)node->data, "break") == 0) {
        // On saute à la fin de la dernière boucle empilée
        if (loop_depth > 0) {
            fprintf(stream, " br WHILE_END_%d\n", loop_stack[loop_depth - 1]);
        }
    } else if (strcmp((char*)node->data, "continue") == 0) {
        // On saute au début de la dernière boucle empilée
        if (loop_depth > 0) {
            fprintf(stream, " br WHILE_START_%d\n", loop_stack[loop_depth - 1]);
        }
    } else if (strcmp((char*)node->data, "true") == 0) {
        fprintf(stream, " ldc.i4 1\n"); // 1 = Vrai
    } else if (strcmp((char*)node->data, "false") == 0) {
        fprintf(stream, " ldc.i4 0\n"); // 0 = Faux
    } else if (strcmp((char*)node->data, "eq") == 0) {
        produce_code(g_node_nth_child(node, 0));
        produce_code(g_node_nth_child(node, 1));
        fprintf(stream, " ceq\n"); // Compare si égal
    } else if (strcmp((char*)node->data, "gt") == 0) {
        produce_code(g_node_nth_child(node, 0));
        produce_code(g_node_nth_child(node, 1));
        fprintf(stream, " cgt\n"); // Compare si plus grand
    } else if (strcmp((char*)node->data, "lt") == 0) {
        produce_code(g_node_nth_child(node, 0));
        produce_code(g_node_nth_child(node, 1));
        fprintf(stream, " clt\n"); // Compare si plus petit
    } else if (strcmp((char*)node->data, "ge") == 0) {
        produce_code(g_node_nth_child(node, 0));
        produce_code(g_node_nth_child(node, 1));
        fprintf(stream, " clt\n");       // Vérifie si A < B
        fprintf(stream, " ldc.i4 0\n");
        fprintf(stream, " ceq\n");       // Compare si A < B est égal à Faux ?

    } else if (strcmp((char*)node->data, "le") == 0) {
        produce_code(g_node_nth_child(node, 0));
        produce_code(g_node_nth_child(node, 1));
        fprintf(stream, " cgt\n");
        fprintf(stream, " ldc.i4 0\n");
        fprintf(stream, " ceq\n");       // Compare A > B est égal à Faux ?
    }
}

int yyerror(const char *msg) {
    fprintf(stderr, "Line %d: %s\n", yylineno, msg);
}
int main(int argc, char *argv[]) {
    if (argc == 2) {
        char *file_name_input = argv[1];
        char *extension;
        char *directory_delimiter;
        char *basename;

        extension = rindex(file_name_input, '.');

        if (!extension || strcmp(extension, ".facile") != 0) {
            fprintf(stderr, "Input filename extension must be '.facile'\n");
            return EXIT_FAILURE;
        }

        directory_delimiter = rindex(file_name_input, '/');
        if (!directory_delimiter) {
            directory_delimiter = rindex(file_name_input, '\\');
        }

        if (directory_delimiter) {
            basename = strdup(directory_delimiter + 1);
        } else {
            basename = strdup(file_name_input);
        }

        module_name = strdup(basename);
        *rindex(module_name, '.') = '\0';
        strcpy(rindex(basename, '.'), ".il");

        char *onechar = module_name;
        if (!isalpha(*onechar) && *onechar != '_') {
            free(basename);
            fprintf(stderr, "Base input filename must start with a letter or an underscore\n");
            return EXIT_FAILURE;
        }

        onechar++;
        while (*onechar) {
            if (!isalnum(*onechar) && *onechar != '_') {
                free(basename);
                fprintf(stderr, "Base input filename cannot contains special characters\n");
                return EXIT_FAILURE;
            }
            onechar++;
        }

        if (stdin = fopen(file_name_input, "r")) {
            if (stream = fopen(basename, "w")) {
                table = g_hash_table_new_full(g_str_hash, g_str_equal, free, NULL);
                yyparse();
                g_hash_table_destroy(table);
                fclose(stream);
                fclose(stdin);
            } else {
                free(basename);
                fclose(stdin);
                fprintf(stderr, "Output filename cannot be opened\n");
                return EXIT_FAILURE;
            }
        } else {
            free(basename);
            fprintf(stderr, "Input filename cannot be opened\n");
            return EXIT_FAILURE;
        }
        free(basename);
    } else {
        fprintf(stderr, "No input filename given\n");
        return EXIT_FAILURE;
    }

    return EXIT_SUCCESS;
}