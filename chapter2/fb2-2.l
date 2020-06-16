%option noyywrap

%{
int lines = 0, total_lines = 0;
int words = 0, total_words = 0;
int chars = 0, total_chars = 0;
%}

%%

[^ \t\n\r\f\v]+  { ++words; chars += strlen(yytext); }
\n               { ++lines; ++chars; }
.                { ++chars; }

%%

int main(int argc, const char **argv) {
    if (argc <= 1) {
        yylex();
        printf("%8d%8d%8d\n", lines, words, chars);
        return 0;
    }

    for (int i = 1; i < argc; ++i) {
        FILE *fp = fopen(argv[i], "r");
        if (!fp) {
            perror(argv[i]);
            return 1;
        }
        yyrestart(fp);
        yylex();
        fclose(fp);
        printf("%8d%8d%8d %s\n", lines, words, chars, argv[i]);
        total_lines += lines; lines = 0;
        total_words += words; words = 0;
        total_chars += chars; chars = 0;
    }

    if (argc > 2) {
        printf("%8d%8d%8d total\n", total_lines, total_words, total_chars);
    }
    return 0;
}