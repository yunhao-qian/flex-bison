#include "ast.h"
#include "dict.h"
#include "func.h"
#include "util.h"
#include <stdlib.h>

#define CALC_NEW(type)                                  \
    ({                                                  \
        type *var = malloc(sizeof(type));               \
        if (!var) {                                     \
            yyerror("fatal error: out of memory");      \
            exit(0);                                    \
        }                                               \
        var;                                            \
    })

struct AST *new_ast(int node_type, struct AST *left, struct AST *right) {
    struct AST *ast = CALC_NEW(struct AST);
    ast->node_type = node_type;
    ast->left = left;
    ast->right = right;
    return ast;
}

struct AST *new_number(double number) {
    struct Number *ast = CALC_NEW(struct Number);
    ast->node_type = 'N';
    ast->number = number;
    return (struct AST *)ast;
}

struct AST *new_func(struct AST *left, int func_type) {
    struct Func *ast = CALC_NEW(struct Func);
    ast->node_type = 'F';
    ast->left = left;
    ast->func_type = func_type;
    return (struct AST *)ast;
}

struct AST *new_ident(char *name) {
    struct Ident *ast = CALC_NEW(struct Ident);
    ast->node_type = 'D';
    ast->name = name;
    return (struct AST *)ast;
}

struct AST *new_if(struct AST *cond, struct AST *then, struct AST *else_br) {
    struct If *ast = CALC_NEW(struct If);
    ast->node_type = 'I';
    ast->cond = cond;
    ast->then = then;
    ast->else_br = else_br;
    return (struct AST *)ast;
}

struct AST *new_while(struct AST *cond, struct AST *then, int check_first) {
    struct While *ast = CALC_NEW(struct While);
    ast->node_type = 'W';
    ast->cond = cond;
    ast->then = then;
    ast->check_first = check_first;
    return (struct AST *)ast;
}

struct AST *new_assign(char *left, struct AST *right) {
    struct Assign *ast = CALC_NEW(struct Assign);
    ast->node_type = 'A';
    ast->left = left;
    ast->right = right;
    return (struct AST *)ast;
}

double eval(struct AST *ast) {
    if (!ast) {
        yyerror("internal error: null evaluation");
        return 0.0;
    }
    switch (ast->node_type) {
    case '+':
        return eval(ast->left) + eval(ast->right);
    case '-':
        return eval(ast->left) - eval(ast->right);
    case '*':
        return eval(ast->left) * eval(ast->right);
    case '/':
        return eval(ast->left) / eval(ast->right);
    case 'M': /* negate */
        return -eval(ast->left);
    case '=':
        return eval(ast->left) == eval(ast->right) ? 1.0 : 0.0;
    case '<':
        return eval(ast->left) < eval(ast->right) ? 1.0 : 0.0;
    case '>':
        return eval(ast->left) > eval(ast->right) ? 1.0 : 0.0;
    case '&':
        {
            double v1 = eval(ast->left);
            return v1 ? eval(ast->right) : v1;
        }
    case '|':
        {
            double v1 = eval(ast->left);
            return v1 ? v1 : eval(ast->right);
        }
    case '!':
        return eval(ast->left) ? 0.0 : 1.0;
    case 'L': /* list */
        eval(ast->left);
        eval(ast->right);
        return 0.0;
    case 'N': /* number */
        return ((struct Number *)ast)->number;
    case 'F': /* function */
        return call_func((struct Func *)ast);
    case 'D': /* identifier */
        {
            char *name = ((struct Ident *)ast)->name;
            int is_new;
            struct Symbol *symbol = look_up(sym_table, name, &is_new);
            if (is_new) {
                yyerror("name error: name %s is not defined", name);
                return 0.0;
            }
            return symbol->number;
        }
    case 'I': /* if */
        {
            struct If *i = (struct If *)ast;
            if (eval(i->cond)) {
                if (i->then) {
                    eval(i->then);
                }
            } else {
                if (i->else_br) {
                    eval(i->else_br);
                }
            }
            return 0.0;
        }
    case 'W': /* while */
        {
            struct While *w = (struct While *)ast;
            if (w->check_first && !eval(w->cond)) {
                return 0.0;
            }
            do {
                eval(w->then);
            } while (eval(w->cond));
            return 0.0;
        }
    case 'A': /* assign */
        {
            struct Assign *a = (struct Assign *)ast;
            struct Symbol *symbol = look_up(sym_table, a->left, NULL);
            symbol->number = eval(a->right);
            return symbol->number;
        }
    default:
        yyerror("internal error: bad node %c", ast->node_type);
        return 0.0;
    }
}

void del_ast(struct AST *ast) {
    if (!ast) {
        return;
    }
    switch (ast->node_type) {
    case '+':
    case '-':
    case '*':
    case '/':
    case 'M':
    case '=':
    case '<':
    case '>':
    case '&':
    case '|':
    case '!':
    case 'L':
    case 'W':
        del_ast(ast->left);
        del_ast(ast->right);
        break;
    case 'N':
        /* do nothing */
        break;
    case 'F':
        del_ast(ast->left);
        break;
    case 'D':
        free(((struct Ident *)ast)->name);
        break;
    case 'I':
        {
            struct If *i = (struct If *)ast;
            del_ast(i->cond);
            del_ast(i->then);
            del_ast(i->else_br);
        }
        break;
    case 'A':
        {
            struct Assign *a = (struct Assign *)ast;
            free(a->left);
            del_ast(a->right);
        }
        break;
    default:
        yyerror("internal error: free bad node %c", ast->node_type);
    }
    /* free the node itself */
    free(ast);
}
