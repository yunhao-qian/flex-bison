#include "dict.h"
#include <stdio.h>

extern FILE *yyin;
int yyparse();

/* main entry of the calculator program */
int main(int argc, const char **argv) {
    if (argc <= 1) {
        fprintf(stderr, "calc: fatal error: no input file\n");
        return 0;
    }
    if (argc > 2) {
        fprintf(stderr, "calc: fatal error: more than 1 input files\n");
        return 0;
    }
    yyin = fopen(argv[1], "r");
    if (!yyin) {
        fprintf(stderr, "calc: fatal error: cannot open file %s\n", argv[1]);
        return 0;
    }
    sym_table = new_dict(0);
    int ret = yyparse();
    del_dict(sym_table);
    return ret;
}
