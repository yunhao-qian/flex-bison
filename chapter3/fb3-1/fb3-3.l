/* recognize tokens for the calculator */

%option noyywrap nodefault yylineno

%{
#include "fb3-1.h"
#include "fb3-2.tab.h"
%}

 /* float exponent */
EXP ([Ee][-+]?[0-9]+)

%%

"+" |
"-" |
"*" |
"/" |
"|" |
"(" |
")"                     { return yytext[0]; }
[0-9]+"."[0-9]*{EXP}? |
"."?[0-9]+{EXP}?        {
                            yylval.val = atof(yytext);
                            return NUM;
                        }

\n                      { return EOL; }
"//".*                  { /* ignore comment */ }
[ \t]                   { /* ignore whitespace */ }
.                       { yyerror("Mystery character %c\n", *yytext); }

%%
