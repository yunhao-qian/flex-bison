#include "func.h"
#include "util.h"
#include <math.h>
#include <stdio.h>

double call_func(struct Func *func) {
    switch (func->func_type) {
    case F_ABS:
        return f_abs(func->left);
    case F_ROUND:
        return f_round(func->left);
    case F_CEIL:
        return f_ceil(func->left);
    case F_FLOOR:
        return f_floor(func->left);
    case F_SQRT:
        return f_sqrt(func->left);
    case F_POW:
        return f_pow(func->left);
    case F_LOG:
        return f_log(func->left);
    case F_PRINT:
        return f_print(func->left);
    default:
        yyerror("internal error: unknown build-in function %d", func->func_type);
        return 0.0;
    }
}

/* extract the only parameter from the AST */
/* report an error if 0 or more than 1 is given */
static double extr_one_param(struct AST *ast, const char *func_name) {
    if (!ast) {
        yyerror("type error: %s takes 1 argument (0 given)", func_name);
        return 0.0;
    }
    if (ast->node_type == 'L') {
        yyerror("type error: %s takes 1 argument (>1 given)", func_name);
        return eval(ast->left);
    }
    return eval(ast);
}

double f_abs(struct AST *ast) {
    double v = extr_one_param(ast, "abs");
    return v < 0.0 ? -v : v;
}

double f_round(struct AST *ast) {
    return round(extr_one_param(ast, "round"));
}

double f_ceil(struct AST *ast) {
    return ceil(extr_one_param(ast, "ceil"));
}

double f_floor(struct AST *ast) {
    return floor(extr_one_param(ast, "floor"));
}

double f_sqrt(struct AST *ast) {
    return sqrt(extr_one_param(ast, "sqrt"));
}

double f_pow(struct AST *ast) {
    if (!ast || ast->node_type != 'L') {
        yyerror("type error: pow takes 2 arguments (%d given)", ast ? 1 : 0);
        return 0.0;
    }
    if (ast->right->node_type == 'L') {
        yyerror("type error: pow takes 2 arguments (>2 given)");
        return pow(eval(ast->left), eval(ast->right->left));
    }
    return pow(eval(ast->left), eval(ast->right));
}

double f_log(struct AST *ast) {
    if (!ast) {
        yyerror("type error: log takes 1 or 2 arguments (0 given)");
        return 0.0;
    }
    if (ast->node_type != 'L') {
        return log(eval(ast));
    }
    if (ast->right->node_type == 'L') {
        yyerror("type error: log takes 1 or 2 arguments (>2 given)");
        return log(eval(ast->left)) / log(eval(ast->right->left));
    }
    return log(eval(ast->left)) / log(eval(ast->right));
}

double f_print(struct AST *ast) {
    if (!ast) {
        printf("\n");
        return 0.0;
    }
    while (ast->node_type == 'L') {
        printf("%G ", eval(ast->left));
        ast = ast->right;
    }
    printf("%G\n", eval(ast));
    return 0.0;
}
