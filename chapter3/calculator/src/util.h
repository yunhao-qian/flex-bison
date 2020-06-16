#ifndef CALC_UTIL_H_
#define CALC_UTIL_H_

/* interface to the lexer */

extern int yylineno;
void yyerror(const char *msg, ...);

#endif /* CALC_UTIL_H_ */
