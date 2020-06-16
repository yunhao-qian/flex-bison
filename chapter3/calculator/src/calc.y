%{
#include "ast.h"
#include "util.h"
#include <stddef.h>

int yylex();
%}

%union {
    double number;
    int func;
    char *ident;
    struct AST *ast;
}

 /* declare tokens */
%token <number> NUMBER
%token <func> FUNC
%token <ident> IDENT
%token IF ELSE WHILE DO
%token ASSIGN

 /* operator precedence */
%right ASSIGN
%left '|'
%left '&'
%left '='
%left '<' '>'
%left '+' '-'
%left '*' '/'
%right NEGATE '!'

 /* non-terminal types */
%type <ast> prog stmt if_stmt while_stmt stmt_list ne_stmt_list expr expr_list ne_expr_list

 /* start symbol */
%start prog

%%

prog:                                                       { $$ = NULL;                    }
    | prog stmt                                             { eval($2); del_ast($2);        }
    ;

stmt: expr ';'
    | if_stmt
    | while_stmt
    ;

if_stmt: IF expr '{' stmt_list '}'                          { $$ = new_if($2, $4, NULL);    }
       | IF expr '{' stmt_list '}' ELSE '{' stmt_list '}'   { $$ = new_if($2, $4, $8);      }
       | IF expr '{' stmt_list '}' ELSE if_stmt             { $$ = new_if($2, $4, $7);      }
       ;

while_stmt: WHILE expr '{' stmt_list '}'                    { $$ = new_while($2, $4, 1);    }
          | DO '{' stmt_list '}' WHILE expr ';'             { $$ = new_while($6, $3, 0);    }

stmt_list:                                                  { $$ = NULL;                    }
         | ne_stmt_list
         ;

ne_stmt_list: stmt
            | stmt ne_stmt_list                             { $$ = new_ast('L', $1, $2);    }
            ;

expr: NUMBER                                                { $$ = new_number($1);          }
    | FUNC '(' expr_list ')'                                { $$ = new_func($3, $1);        }
    | IDENT                                                 { $$ = new_ident($1);           }
    | expr '+' expr                                         { $$ = new_ast('+', $1, $3);    }
    | expr '-' expr                                         { $$ = new_ast('-', $1, $3);    }
    | expr '*' expr                                         { $$ = new_ast('*', $1, $3);    }
    | expr '/' expr                                         { $$ = new_ast('/', $1, $3);    }
    | '-' expr %prec NEGATE                                 { $$ = new_ast('M', $2, NULL);  }
    | expr '=' expr                                         { $$ = new_ast('=', $1, $3);    }
    | expr '<' expr                                         { $$ = new_ast('<', $1, $3);    }
    | expr '>' expr                                         { $$ = new_ast('>', $1, $3);    }
    | expr '&' expr                                         { $$ = new_ast('&', $1, $3);    }
    | expr '|' expr                                         { $$ = new_ast('|', $1, $3);    }
    | '!' expr                                              { $$ = new_ast('!', $2, NULL);  }
    | '(' expr ')'                                          { $$ = $2;                      }
    | IDENT ASSIGN expr                                     { $$ = new_assign($1, $3);      }
    ;

expr_list:                                                  { $$ = NULL;                    }
         | ne_expr_list
         ;

ne_expr_list: expr
            | expr ',' ne_expr_list                         { $$ = new_ast('L', $1, $3);    }
            ;

%%
