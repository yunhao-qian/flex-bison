#ifndef CALC_AST_H_
#define CALC_AST_H_

/* node types
 * + - * / = < > & | !
 * A assignment
 * D identifier
 * F built-in function call
 * I if statement
 * L expression or statement list
 * M negate
 * N number
 * W while statement
 */

enum FuncType {
    F_ABS = 1,
    F_ROUND,
    F_CEIL,
    F_FLOOR,
    F_SQRT,
    F_POW,
    F_LOG,
    F_PRINT
};

/* nodes in the AST all have common initial node_type */
struct AST {
    int node_type;
    struct AST *left, *right;
};

struct Number {
    int node_type;              /* type N */
    double number;
};

struct Func {
    int node_type;              /* type F */
    struct AST *left;
    enum FuncType func_type;
};

struct Ident {
    int node_type;              /* type D */
    char *name;
};

struct If {
    int node_type;              /* type I */
    struct AST *cond, *then;
    struct AST *else_br;
};

struct While {
    int node_type;              /* type W */
    struct AST *cond, *then;
    int check_first;
};

struct Assign {
    int node_type;              /* type A */
    char *left;
    struct AST *right;
};

/* build an AST */
struct AST *new_ast(int node_type, struct AST *left, struct AST *right);
struct AST *new_number(double number);
struct AST *new_func(struct AST *left, int func_type);
struct AST *new_ident(char *name);
struct AST *new_if(struct AST *cond, struct AST *then, struct AST *else_br);
struct AST *new_while(struct AST *cond, struct AST *then, int check_first);
struct AST *new_assign(char *left, struct AST *right);

/* evaluate an AST */
double eval(struct AST *ast);

/* delete an AST */
void del_ast(struct AST *ast);

#endif /* CALC_AST_H_ */
