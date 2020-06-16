#ifndef FB3_2_H_
#define FB3_2_H_

/* interface to the lexer */
extern int yylineno;
void yyerror(const char *s, ...);

/* symbol table */
struct Symbol {
    const char *name;
    double value;
    struct AST *func;
    struct SymList *syms;
};

/* simple sym_table of fixed size */
#define NHASH 9997
struct Symbol sym_table[NHASH];

struct Symbol *lookup(const char *name);

/* list of symbols, for an argument list */
struct SymList {
    struct Symbol *sym;
    struct SymList *next;
};

struct SymList *new_sym_list(struct Symbol *sym, struct SymList *next);
void del_sym_list(struct SymList *list);

/* node types
 * + - * / |
 * 0-7 comparison ops, bit coded 04 equal, 02 less, 01 greater
 * M unary minus
 * L expression or statement list
 * I IF statement
 * W WHILE statement
 * N symbol ref
 * = assignment
 * S list of symbols
 * F built in function call
 * C user function call
 */

enum BIFuncs { B_sqrt = 1, B_exp, B_log, B_print };

/* nodes in the abstract syntax tree */
/* all have common initial node type */

struct AST {
    int node_type;
    struct AST *l, *r;
};

struct FuncCall {  /* built-in function */
    int node_type; /* type F */
    struct AST *l;
    enum BIFuncs func_type;
};

struct UFuncCall { /* user function */
    int node_type; /* type C */
    struct AST *l; /* list of arguments */
    struct Symbol *sym;
};

struct Flow {
    int node_type;    /* type I or W */
    struct AST *cond; /* condition */
    struct AST *then; /* then branch or do list */
    struct AST *el;   /* optional else branch */
};

struct NumVal {
    int node_type; /* type K */
    double val;
};

struct SymRef {
    int node_type; /* type N */
    struct Symbol *sym;
};

struct SymAssign {
    int node_type; /* type = */
    struct Symbol *sym;
    struct AST *val;
};

struct AST *new_ast(int node_type, struct AST *l, struct AST *r);
struct AST *new_cmp(int cmp_type, struct AST *l, struct AST *r);
struct AST *new_func(int func_type, struct AST *l);
struct AST *new_call(struct Symbol *s, struct AST *l);
struct AST *new_assign(struct Symbol *s, struct AST *v);

#endif /* FB3_2_H_ */