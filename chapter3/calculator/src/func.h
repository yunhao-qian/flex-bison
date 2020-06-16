#ifndef CALC_FUNC_H_
#define CALC_FUNC_H_

#include "ast.h"

/* built-in functions of the calculator */

double call_func(struct Func *func);

/* takes 1 argument */
double f_abs(struct AST *ast);
double f_round(struct AST *ast);
double f_ceil(struct AST *ast);
double f_floor(struct AST *ast);
double f_sqrt(struct AST *ast);

/* takes 2 arguments (base and exponent) */
double f_pow(struct AST *ast);

/* takes 1 or 2 arguments */
/* use natural logarithm if base is omitted */
double f_log(struct AST *ast);

/* takes any number of arguments (including 0) */
double f_print(struct AST *ast);

#endif /* CALC_FUNC_H_ */
