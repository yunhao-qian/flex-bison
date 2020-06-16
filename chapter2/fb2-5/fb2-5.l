 /* fb2-5 C cross-referencer */

%option noyywrap nodefault yylineno

%x COMMENT
%x IFILE

 /* some complex named patterns */

 /* univeral character name */
UCN (\\u[0-9A-Fa-f]{4}|\\U[0-9A-Fa-f]{8})

 /* float exponent */
EXP ([Ee][-+]?[0-9]+)

 /* integer length */
ILEN ([Uu](L|l|LL|ll)?|(L|l|LL|ll)[Uu]?)

 /* the symbol table */
%{

struct Ref {
    struct Ref *next;
    const char *filename;
    int flags;
    int lineno;
};

struct Symbol {
    struct Ref *ref_list;
    const char *name;
};

/* simple symbol table of fixed size */
#define NHASH 9997
struct Symbol sym_table[NHASH];

struct Symbol *lookup(const char *word);
void add_ref(int lineno, const char *filename, const char *word, int flags);
void print_refs();
int push_file(const char *filename);
int pop_file();

/* name of the current input file */
const char *curr_filename = NULL;

/* include file stack */
struct BufStack {
    struct BufStack *prev;
    YY_BUFFER_STATE state;
    int lineno;
    const char *filename;
    FILE *file;
} *curbs = NULL;

int push_file(const char *filename);
int pop_file();

/* names are probably definitions */
int defining = 0;

%}

%%

 /* comments */
"/*"                                    { BEGIN COMMENT; }
<COMMENT>"*/"                           { BEGIN INITIAL; }
<COMMENT>([^*]|\n)+|.
<COMMENT><<EOF>>                        {
                                            printf("%s:%d: Unterminated comment\n", curr_filename, yylineno);
                                            return 0;
                                        }

 /* C++ comment, a common extension */
"//".*\n

 /* declaration keywords */
_Bool       |
_Complex    |
_Imaginary  |
auto        |
char        |
const       |
double      |
enum        |
extern      |
float       |
inline      |
int         |
long        |
register    |
restrict    |
short       |
signed      |
static      |
struct      |
typedef     |
union       |
unsigned    |
void        |
volatile                                { defining = 1; }

 /* keywords */
break
case
continue
default
do
else
for
goto
if
return
sizeof
switch
while

 /* constants */

 /* integers */
0[0-7]*{ILEN}?
[1-9][0-9]*{ILEN}?
0[Xx][0-9A-Fa-f]+{ILEN}?

 /* decimal float */
([0-9]*\.[0-9]+|[0-9]+\.){EXP}?[FfLl]?
[0-9]+{EXP}[FfLl]?

 /* hex float */
0[Xx]([0-9A-Fa-f]*\.[0-9A-Fa-f]+|[0-9A-Fa-f]+\.?)[Pp][-+]?[0-9]+[FfLl]?

 /* char const */
\'([^'\\]|\\['"?\\abfnrtv]|\\[0-7]{1,3}|\\[Xx][0-9A-Fa-f]+|{UCN})+\'

 /* string literal */
L?\"([^"\\]|\\['"?\\abfnrtv]|\\[0-7]{1,3}|\\[Xx][0-9A-Fa-f]+|{UCN})*\"

 /* punctuators */
"{"|"<%"|";"                            { defining = 0; }

"["|"]"|"("|")"|"{"|"}"|"."|"->"
"++"|"--"|"&"|"*"|"+"|"-"|"~"|"!"
"/"|"%"|"<<"|">>"|"<"|">"|"<="|">="|"=="|"!="|"^"|"|"|"&&"|"||"
"?"|":"|";"|"..."
"="|"*="|"/="|"%="|"+="|"-="|"<<="|">>="|"&="|"^="|"|="
","|"#"|"##"
"<:"|":>"|"%>"|"%:"|"%:%:"

 /* identifier */
([_A-Za-z]|{UCN})([_0-9A-Za-z]|{UCN})*   { add_ref(yylineno, curr_filename, yytext, defining); }

 /* whitespace */
[ \t\n]+

 /* continued line */
\\$

 /* preprocessor */
"#"" "*if.*\n
"#"" "*else.*\n
"#"" "*endif.*\n
"#"" "*define.*\n
"#"" "*line.*\n

 /* recognize an include */
^"#"[ \t]*include[ \t]*[\"<]            { BEGIN IFILE; }
<IFILE>[^>\"]+                          {
                                            int c;
                                            do {
                                                c = input();    
                                            } while (c != '\n');
                                            push_file(strdup(yytext));
                                            BEGIN INITIAL;
                                        }
<IFILE>.|\n                             {
                                            printf("%s:%d: Bad include line\n", curr_filename, yylineno);
                                            BEGIN INITIAL;
                                        }
<<EOF>>                                 {
                                            if (!pop_file()) {
                                                yyterminate();
                                            }
                                        }
 /* invalid character */
.                                       { printf("%s:%d: Mystery character '%s'\n", curr_filename, yylineno, yytext); }

%%

int main(int argc, const char **argv) {
    if (argc <= 1) {
        printf("Need filename\n");
        return 1;
    }
    for (int i = 1; i < argc; ++i) {
        if (push_file(argv[i])) {
            yylex();
        }
    }
    print_refs();
    return 0;
}

unsigned sym_hash(const char *symbol) {
    unsigned hash = 0, c;
    while (c = *symbol++) {
        hash = hash * 9 ^ c;
    }
    return hash;
}

struct Symbol *lookup(const char *word) {
    struct Symbol *symbol = sym_table + sym_hash(word) % NHASH;
    for (int count = NHASH; count > 0; --count) {
        if (symbol->name && !strcmp(symbol->name, word)) {
            return symbol;
        }
        if (!symbol->name) {
            symbol->name = strdup(word);
            symbol->ref_list = NULL;
            return symbol;
        }
        if (++symbol == sym_table + NHASH) {
            symbol = sym_table;
        }
    }
    printf("Symbol table overflow\n");
    abort();
}

void add_ref(int lineno, const char *filename, const char *word, int flags) {
    struct Symbol *symbol = lookup(word);
    if (symbol->ref_list && symbol->ref_list->lineno == lineno && symbol->ref_list->filename == filename) {
        return;
    }

    struct Ref *ref = malloc(sizeof(struct Ref));
    if (!ref) {
        printf("Out of space\n");
        abort();
    }
    ref->next = symbol->ref_list;
    ref->filename = filename;
    ref->lineno = lineno;
    ref->flags = flags;
    symbol->ref_list = ref;
}

int sym_compare(const void *xa, const void *xb) {
    const struct Symbol *a = xa, *b = xb;
    if (!a->name) {
        return b->name ? 1 : 0;
    }
    if (!b->name) {
        return -1;
    }
    return strcmp(a->name, b->name);
}

void print_refs() {
    qsort(sym_table, NHASH, sizeof(struct Symbol), sym_compare);
    for (struct Symbol *p = sym_table; p->name && p < sym_table + NHASH; ++p) {
        struct Ref *prev = NULL, *curr = p->ref_list, *next;
        do {
            next = curr->next;
            curr->next = prev;
            prev = curr;
            curr = next;
        } while (curr);

        printf("%10s", p->name);
        const char *prev_filename = NULL;
        for (curr = prev; curr; curr = curr->next) {
            if (curr->filename == prev_filename) {
                printf(" %d", curr->lineno);
            } else {
                printf(" %s:%d", curr->filename, curr->lineno);
                prev_filename = curr->filename;
            }
            if (curr->flags & 1) {
                printf("*");
            }
        }
        printf("\n");
    }
}

int push_file(const char *filename) {
    FILE *file = fopen(filename, "r");
    struct BufStack *stack = malloc(sizeof(struct BufStack));

    if (!file) {
        perror(filename);
        return 0;
    }
    if (!stack) {
        perror("malloc");
        abort();
    }

    if (curbs) {
        curbs->lineno = yylineno;
    }
    stack->prev = curbs;

    stack->state = yy_create_buffer(file, YY_BUF_SIZE);
    stack->file = file;
    stack->filename = filename;
    yy_switch_to_buffer(stack->state);
    curbs = stack;
    yylineno = 1;
    curr_filename = filename;
    return 1;
}

int pop_file() {
    if (!curbs) {
        return 0;
    }

    fclose(curbs->file);
    yy_delete_buffer(curbs->state);

    struct BufStack *prev = curbs->prev;
    free(curbs);
    curbs = prev;

    if (!curbs) {
        return 0;
    }

    yy_switch_to_buffer(curbs->state);
    yylineno = curbs->lineno;
    curr_filename = curbs->filename;
    return 1;
}
