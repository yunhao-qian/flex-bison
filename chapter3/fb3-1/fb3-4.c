#include "fb3-1.h"
#include "fb3-2.tab.h"
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>

struct AST *new_ast(int node_type, struct AST *l, struct AST *r) {
    struct AST *tree = malloc(sizeof(struct AST));
    if (!tree) {
        yyerror("Out of space");
        exit(0);
    }
    tree->node_type = node_type;
    tree->l = l;
    tree->r = r;
    return tree;
}

struct AST *new_num(double val) {
    struct NumVal *num = malloc(sizeof(struct NumVal));
    if (!num) {
        yyerror("Out of space");
        exit(0);
    }
    num->node_type = 'K';
    num->val = val;
    return (struct AST *)num;
}

double eval(struct AST *tree) {
    double ret;
    switch (tree->node_type) {
    case 'K':
        ret = ((struct NumVal *)tree)->val;
        break;
    case '+':
        ret = eval(tree->l) + eval(tree->r);
        break;
    case '-':
        ret = eval(tree->l) - eval(tree->r);
        break;
    case '*':
        ret = eval(tree->l) * eval(tree->r);
        break;
    case '/':
        ret = eval(tree->l) / eval(tree->r);
        break;
    case '|':
        ret = eval(tree->l);
        if (ret < 0) {
            ret = -ret;
        }
        break;
    case 'M':
        ret = -eval(tree->l);
        break;
    default:
        printf("Internal error: bad node %c\n", tree->node_type);
    }
    return ret;
}

void del_ast(struct AST *tree) {
    switch (tree->node_type) {
    case '+':
    case '-':
    case '*':
    case '/':
        del_ast(tree->r);
    case '|':
    case 'M':
        del_ast(tree->l);
    case 'K':
        free(tree);
        break;
    default:
        printf("Internal error: bad node %c\n", tree->node_type);
    }
}

void yyerror(const char *s, ...) {
    va_list ap;
    va_start(ap, s);

    fprintf(stderr, "%d: Error: ", yylineno);
    vfprintf(stderr, s, ap);
    fprintf(stderr, "\n");
}

int main() {
    printf("> ");
    return yyparse();
}