# Using Flex

`[]`: character class.
* A `-` or `]` as the first character after `[` is interpreted literally to include them in the class.
* C escape sequences starting with `\` are recognized.
* Character ranges are interpreted according to the coding. (Ex. `[A-z]` includes the six punctuation letters between.)

`[a-z]{-}[jv]`: accepts the characters in the first class and then omit the characters in the second class.

* `^` beginning of a line as the first character of regular expression.
* `$` end of a line as the last character of regular expression.

`{}`:
* `A{1, 3}` means 1, 2, or 3 occurrences of `A`.
* `0{5}` means 5 occurrences of `0` (that is `00000`).

`faith|hope|charity` matches `faith`, `hope` or `charity`

Inside `"..."` anything but C escape sequence inside is treated literally.

`/`: trailing context
* `0/1` matches `0` in the string `01` but not `0` in `02`.
* Only one slash is permitted per pattern.

Repetition operators affect the smallest preceding expression:
* `abc+` = `ab` with multiple `c`s.
* `(abc)+` = multiple `abc`s.

When multiple patterns can match the same input:
* Matches the longest possible string;
* In the case of a tie (same length), use the pattern that appears first in the program.

Context dependent tokens:
* Ex. `int apple();` can be either a function declaration or a function call.
* Start state: turn patterns on and off dynamically.

IO:
* A scanner by default reads from `FILE yyin;`
* If not specified, `yyin` is set to `stdin`.

About `yywrap()`:
* When a scanner reaches the end of `yyin`, it calls `yywrap()`.
  1. If there is another file, `yywrap()` adjusts `yyin` and returns `0`.
  2. If it is done, `yywrap()` returns 0.
  > Default `yywrap()` always returns 1.
  > However, it is more often not to call `yywrap()` by specifying `%option noyywrap`.

Input system (ex. read char, line or chunk at a time):
* If reading from a file, it should read big chunks to be as fast as possible.
* If reading from a console, it should read char by char so that it can return the result as soon as newline is hit.
* Flex scanner checks the input type and does the correct thing automatically.

1. Set `yyin` to the desired files;
2. structure `YY_BUFFER_STATE`:
   ```c
   YY_BUFFER_STATE bp;
   extern FILE *yyin;

   if (!yyin)
       yyin = stdin;

   bp = yy_create_buffer(yyin, YY_BUFFER_SIZE);
   // Other ways:
   // yy_scan_string("It is the best of the times.");
   // yy_scan_buffer(char *base, int size);

   yy_switch_to_buffer(bp);

   yylex();

   // equivalent to yyrestart(new_value);
   yyin = <new_value>
   YY_NEW_FILE;
   ```
3. Redefine `YY_INPUT` (used to read input from current buffer):
   ```C
   #define YY_INPUT(buf, result, max_size) ...
   ```

Flex macros: `input` and `unput`
* `input()` returns the next character from the input stream;
* `unput(c)` pushes the character back into the input stream.

`%option nodefault`
* By default, flex output any unmatched characters to `yyout`:
  ```
  .  { fwrite(yytext, yyleng, 1, yyout); }
  ```
* By using `nodefault`, flex reports and error if rules do not cover all possible input.

`<<EOF>>`: end-of-file pattern.

## Symbol Table

Concordance: tracks each word, and its file and line number.

`%option case-insensitive`:
* `abc` will match `abc`, `Abc`, `aBc`, ...;
* It *does not* have any effect on the input.

Action that consists solely a vertical bar `|`:
it has the same action as for the text rule.

Strings in `yytext` exists only until the next token is scanned.

## C Cross Reference

Match comments with 3 patterns:
```
"/*"                  { BEGIN COMMENT; }
<COMMENT>"*/"         { BEGIN INITIAL; }
<COMMENT>([^*]|\n)+|.
<COMMENT><<EOF>>      { printf("%s:%d: Unterminated comment\n", currfilename, yylineno); }

/* C++ comment extension */
"//".*\n
```

Actually, comment can be matched with 1 single pattern:
```
/\*([^*]|\*+[^/*])*\*+/
```
Why not use it:
* A flex token is limited to the size of input buffer (16K) -> bugs.
* Easier to catch unclosed comments.

-- page 47 --