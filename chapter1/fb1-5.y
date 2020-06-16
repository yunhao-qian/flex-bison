%{
#include <stdio.h>

int yylex();
int yyerror(const char *s);
%}

%token NUMBER
%token ADD SUB MUL DIV ABS
%token AND OR
%token EOL
%token OP CP

%%

calclist:
    | calclist exp EOL { printf("= %d %#x\n", $2, $2); }
    ;

exp: orcond
    | exp OR orcond { $$ = $1 | $3; }

orcond: andcond
    | orcond AND andcond { $$ = $1 & $3; }

andcond: factor
    | exp ADD factor { $$ = $1 + $3; }
    | exp SUB factor { $$ = $1 - $3; }
    ;

factor: term
    | factor MUL term { $$ = $1 * $3; }
    | factor DIV term { $$ = $1 / $3; }
    ;

term: NUMBER
    | ABS term { $$ = $2 > 0 ? $2 : -$2; }
    | OP exp CP { $$ = $2; }
    ;

%%

int main(int argc, const char **argv) {
    yyparse();
}

int yyerror(const char *s) {
    fprintf(stderr, "error: %s\n", s);
    return 0;
}