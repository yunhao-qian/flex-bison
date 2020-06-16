#include "util.h"
#include <stdarg.h>
#include <stdio.h>

void yyerror(const char *msg, ...) {
    va_list ap;
    va_start(ap, msg);
    fprintf(stderr, "%d: ", yylineno);
    vfprintf(stderr, msg, ap);
    fprintf(stderr, "\n");
}
