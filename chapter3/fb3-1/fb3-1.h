#ifndef FB3_1_H_
#define FB3_1_H_

// interface to lexer
extern int yylineno;
void yyerror(const char *s, ...);

struct AST {
    int node_type;
    struct AST *l, *r;
};

struct NumVal {
    int node_type;
    double val;
};

// build an AST
struct AST *new_ast(int node_type, struct AST *l, struct AST *r);
struct AST *new_num(double val);

// evaluate an AST
double eval(struct AST *);

// delete and free an AST
void del_ast(struct AST *);

#endif // FB3_1_H_