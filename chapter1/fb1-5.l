%{
#include "fb1-5.tab.h"
%}

%%

[0-9]+       { yylval = atoi(yytext); return NUMBER; }
0x[a-f0-9]+  { yylval = strtol(yytext, NULL, 16); return NUMBER; }
"+"          { return ADD; }
"-"          { return SUB; }
"*"          { return MUL; }
"/"          { return DIV; }
abs          { return ABS; }
"&"          { return AND; }
"|"          { return OR; }
\n           { return EOL; }
[ \t]        {}
"("          { return OP; }
")"          { return CP; }
"//".*       {}
.            { printf("Mystery character %c\n", *yytext); }

%%