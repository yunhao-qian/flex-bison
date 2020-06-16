# Introducing Flex and Bison

## Flex

A flex program consists of 3 sections, separated by `%%` lines.
1. Declarations & option settings.
   * Code inside `%{ %}` is copied near the beginning of the generated C source file.
2. Patterns & actions.
   * Each pattern *must* start at the beginning of a line.
   * Lines that start with a whitespace are copied into the generated C program.
   * The C code can be one statement or a multiple block in braces `{}`.
   * `yytext` points to the text that the pattern just matched.
   * `.` (dot) matches any character.
3. C code that is copied to the scanner.

Compile and run:
(`-lfl`: link it with the flex library)
```
$ flex fb1-1.l
$ cc lex.yy.c -lfl
$ ./a.out
Pumas are large cat like animals
which are found in America
^D
chars: 60
words: 11
lines: 2
$
```

The original [a-zA-Z]+ pattern only accepts English words. Replace it with a pattern that rejects only whitespace characters:
```
[^ \t\n\r\f\v]+
```

Quote a string to tell flex to treat it as it is, rather than interpreting them as regular expressions.

* Flex scanners => a stream of tokens => handled by a parser.
* Each time the program needs a token, it calls `yylex()`.

The scanner acts as a coroutine:
* Each time it returns, it remembers where it is.
* On the next call it picks up where it lefts off.

The action code may or may not return a token:
* If the action code has a token ready, it just returns it from `yylex()`.
* Otherwise, the scanner will keep going within the same call.

Example: ignore whitespace by not returning a token.
```
"+"     { return ADD; }
[0-9]+  { return NUMBER; }
[ \t]   {}
```

Each token has two parts:
* The token: a small integer.
  > Bison assigns the token numbers automatically from 258 and
  > creates a `.h` with their definitions.
  > (To avoid collisions with literal number tokens.)
* The token's *value*.
  > Tell it apart from its similar tokens.
  > (Ex. the exact value of a floating-point number.)

## Bison

The standard form to write down a context-free grammar (CFG) is Backus-Naur Form (BNF).

BNF Example:
```
<exp> ::= <factor>
      | <exp> + <factor>
<factor> ::= NUMBER
      | <factor> * NUMBER
```

* `::=` is "becomes";
* `|` is "or" (another way to create a branch of the same kind).
* By convention, all tokens are considered symbols,
  but there are symbols that are not tokens.

Bison syntax:
* To declare a token: `%token NUMBER`
  Any symbols not declared as tokens have to appear on the left side of a rule.
* A semicolon marks the end of a rule.
* Each symbol in a bison rule has a value.
  > Target symbol called `$$` in the action code.
  > Values on the right called `$1`, `$2`, ...
* If no action code, a 1-1 rule assigns `$1` to `$$`.

When bison runs in `-d` (definition) mode, it creates both `fb1-5.tab.c` and `fb1-5.tab.h` files.

Deal with precedence: use separate symbols for `exp`, `term` and `factor`.
> Bison has special features so that this tedious work is not needed.

Bison will not parse an ambiguous grammar, such as:
```
exp: exp ADD exp
   | exp SUB exp
   | factor
```
In the "grammar" above, `1 - 2 + 3` can be parsed either as `(1 - 2) + 3` or `1 - (2 + 3)`, which caused a conflict.

A conflict can also caused by more than 1 token of lookahead. Rewrite the rules so that 1 token lookahead is enough.