/* calculator with AST */

%{
#include <stdio.h>
#include <stdlib.h>
#include "fb3-1.h"

int yylex();
%}

%union {
    struct AST *tree;
    double val;
}

 /* declare tokens */
%token <val> NUM;
%token EOL

%type <tree> expr factor term

%%

calc_list: /* nothing */
    | calc_list expr EOL    {
                                printf("= %4.4g\n", eval($2));
                                del_ast($2);
                                printf("> ");
                            }
    | calc_list EOL         { printf("> "); }  /* blank line or a comment */
    ;

expr: factor
    | expr '+' factor       { $$ = new_ast('+', $1, $3); }
    | expr '-' factor       { $$ = new_ast('-', $1, $3); }
    ;

factor: term
    | factor '*' term       { $$ = new_ast('*', $1, $3); }
    | factor '/' term       { $$ = new_ast('/', $1, $3); }
    ;

term: NUM                   { $$ = new_num($1); }
    | '|' term              { $$ = new_ast('|', $2, NULL); }
    | '(' expr ')'          { $$ = $2; }
    | '-' term              { $$ = new_ast('M', $2, NULL); }
    ;

%%
