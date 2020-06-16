%option nodefault
%option noyywrap

%x INCLUDE_FILE

%{

struct BufferStack {
    struct BufferStack *previous;
    YY_BUFFER_STATE state;
    int line_number;
    const char *file_name;
    FILE *file;
} *curbs = NULL;

const char *current_file_name;

int push_file(const char *file_name);
int pop_file();

%}

%%

^"#"[ \t]*include[ \t]*[\"<] { BEGIN INCLUDE_FILE; }

<INCLUDE_FILE>[^ \t\n\">]+  {
                                int c;
                                do {
                                    c = input();
                                } while (c != '\n');
                                ++yylineno;
                                if (!push_file(yytext)) {
                                    yyterminate();
                                }
                                BEGIN INITIAL;
                            }

<INCLUDE_FILE>.|\n          {
                                fprintf(stderr, "%4d bad include line\n", yylineno);
                                yyterminate();
                            }

<<EOF>>                     {
                                if (!pop_file()) {
                                    yyterminate();
                                }
                            }

^.                          { fprintf(yyout, "%4d %s", yylineno, yytext); }
^\n                         { fprintf(yyout, "%4d %s", yylineno++, yytext); }

\n                          {
                                ECHO;
                                ++yylineno;
                            }

.                           { ECHO; }

%%

int main(int argc, const char **argv) {
    if (argc <= 1) {
        fprintf(stderr, "need file name\n");
        return 1;
    }
    if (push_file(argv[1])) {
        yylex();
    }
}

int push_file(const char *file_name) {
    FILE *file = fopen(file_name, "r");
    struct BufferStack *stack = malloc(sizeof(struct BufferStack));

    if (!file) {
        perror(file_name);
        return 0;
    }
    if (!stack) {
        perror("malloc");
        exit(1);
    }

    if (curbs) {
        curbs->line_number = yylineno;
    }
    stack->previous = curbs;

    stack->state = yy_create_buffer(file, YY_BUF_SIZE);
    stack->file = file;
    stack->file_name = file_name;
    yy_switch_to_buffer(stack->state);
    curbs = stack;
    yylineno = 1;
    current_file_name = file_name;
    return 1;
}

int pop_file() {
    if (!curbs) {
        return 0;
    }

    fclose(curbs->file);
    yy_delete_buffer(curbs->state);

    struct BufferStack *previous = curbs->previous;
    free(curbs);

    if (!previous) {
        return 0;
    }

    yy_switch_to_buffer(previous->state);
    curbs = previous;
    yylineno = curbs->line_number;
    current_file_name = curbs->file_name;
    return 1;
}