%{
int chars = 0;
int words = 0;
int lines = 0;
%}

%%

[^ \t\n\r\f\v]+  { ++words; chars += strlen(yytext); }
\n               { ++chars; ++lines; }
.                { ++chars; }

%%

int main() {
    yylex();
    printf("chars: %d\nwords: %d\nlines: %d\n", chars, words, lines);
}