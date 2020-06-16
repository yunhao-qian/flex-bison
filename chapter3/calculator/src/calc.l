 /* recognize tokens for the calculator */

%option noyywrap nodefault yylineno

%{
#include "ast.h"
#include "calc.tab.h"
#include "util.h"
%}

 /* unsigned integer */
UINT ([1-9][0-9]*)

%%

 /* single character operators */
"+" |
"-" |
"*" |
"/" |
"=" |
"<" |
">" |
"&" |
"|" |
"!" |
"(" |
")" |
"{" |
"}" |
"," |
";"                                     { return yytext[0]; }

":="                                    { return ASSIGN;    }

 /* keywords */
"if"                                    { return IF;        }
"else"                                  { return ELSE;      }
"while"                                 { return WHILE;     }
"do"                                    { return DO;        }

 /* built-in functions */
"abs"                                   { yylval.func = F_ABS; return FUNC;     }
"round"                                 { yylval.func = F_ROUND; return FUNC;   }
"ceil"                                  { yylval.func = F_CEIL; return FUNC;    }
"floor"                                 { yylval.func = F_FLOOR; return FUNC;   }
"sqrt"                                  { yylval.func = F_SQRT; return FUNC;    }
"pow"                                   { yylval.func = F_POW; return FUNC;     }
"log"                                   { yylval.func = F_LOG; return FUNC;     }
"print"                                 { yylval.func = F_PRINT; return FUNC;   }

 /* identifier */
[A-Za-z][_0-9A-Za-z]*                   { yylval.ident = strdup(yytext); return IDENT;  }

 /* number */
({UINT}|{UINT}?.[0-9]+)([Ee]-?{UINT})?  { yylval.number = atof(yytext); return NUMBER;  }

 /* comment and whitespace */
"//".*
[ \t]

 /* linebreak and line continuation */
\n
\\\n

.                                       { yyerror("syntax error: unknown character %c\n", yytext[0]);   }

%%
