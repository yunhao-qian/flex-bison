%option noyywrap nodefault yylineno case-insensitive

%{
struct Ref {
    struct Ref *next;
    char *file_name;
    int flags;
    int line_number;
};

struct Symbol {
    char *name;
    struct Ref *ref_list;
};

#define N_HASH 9997
struct Symbol sym_table[N_HASH];

struct Symbol *look_up(char *symbol);
void add_ref(int line_number, char *file_name, char *word, int flags);
void print_refs();

char *curr_file_name;
%}

%%

a    |
an   |
and  |
are  |
as   |
at   |
be   |
but  |
for  |
in   |
is   |
it   |
of   |
on   |
or   |
that |
the  |
this |
to     /* ignore */

[a-z]+(\'(s|t))?  { add_ref(yylineno, curr_file_name, yytext, 0); }
.|\n              /* ignore everything else */

%%

int main(int argc, char **argv) {
    if (argc <= 1) {
        curr_file_name = "(stdin)";
        yylineno = 1;
        yylex();
    } else {
        for (int i = 1; i < argc; ++i) {
            FILE *file = fopen(argv[i], "r");
            if (!file) {
                perror(argv[i]);
                return 1;
            }
            curr_file_name = argv[i];

            yyrestart(file);
            yylineno = 1;
            yylex();
            fclose(file);
        }
    }

    print_refs();
}

unsigned sym_hash(char *symbol) {
    unsigned hash = 0, c;
    while (c = *symbol++) {
        hash = hash * 9 ^ c;
    }
    return hash;
}

struct Symbol *look_up(char *symbol) {
    struct Symbol *p = sym_table + sym_hash(symbol) % N_HASH;
    for (int count = N_HASH; count >= 0; --count) {
        if (p->name && !strcmp(p->name, symbol)) {
            return p;
        }
        // new entry
        if (!p->name) {
            p->name = strdup(symbol);
            p->ref_list = NULL;
            return p;
        }
        // try the next entry
        if (++p >= sym_table + N_HASH) {
            p = sym_table;
        }
    }
    fputs("symbol table overflow\n", stderr);
    abort();
}

void add_ref(int line_number, char *file_name, char *word, int flags) {
    struct Symbol *symbol = look_up(word);
    // do not do dups of same line and file
    if (symbol->ref_list && symbol->ref_list->line_number == line_number &&
        symbol->ref_list->file_name == file_name) {
        return;
    }

    struct Ref *ref = malloc(sizeof(struct Ref));
    if (!ref) {
        fputs("out of space\n", stderr);
        abort();
    }
    ref->next = symbol->ref_list;
    ref->file_name = file_name;
    ref->line_number = line_number;
    ref->flags = flags;
    symbol->ref_list = ref;
}

int sym_compare(const void *xa, const void *xb) {
    const struct Symbol *a = xa, *b = xb;
    // put empty symbols at the end
    if (!a->name) {
        return b->name ? 1 : 0;
    }
    if (!b->name) {
        return -1;
    }
    return strcmp(a->name, b->name);
}

void print_refs() {
    qsort(sym_table, N_HASH, sizeof(struct Symbol), sym_compare);
    for (struct Symbol *p = sym_table; p->name && p < sym_table + N_HASH; ++p) {
        char *prev_file_name = NULL;
        struct Ref *prev = NULL, *curr = p->ref_list, *next;

        // reverse the list
        do {
            next = curr->next;
            curr->next = prev;
            prev = curr;
            curr = next;
        } while (curr);

        printf("%10s", p->name);
        for (curr = prev; curr; curr = curr->next) {
            if (curr->file_name == prev_file_name) {
                printf(" %d", curr->line_number);
            } else {
                printf(" %s:%d", curr->file_name, curr->line_number);
                prev_file_name = curr->file_name;
            }
        }
        printf("\n");
    }
}