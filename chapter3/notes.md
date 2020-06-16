# Using Bison

Program:
* syntactically valid (what bison deals with);
* semantically valid (ex. cannot assign string to a int). 

Terminals and non-terminals must be different.
It is an error to write a rule with a token (terminal) on the left-hand side (LHS).

Shift:
```
fred
fred =
fred = 12
fred = 12 +
fred = 12 + 13
```

Reduction:
```
fred = expression
statement
```

Two parsing models:
* LALR(1) (look ahead left to right with a one-token lookahead)
  > Less powerful; considerably faster and easier to use.
* GLR (generalized left to right)

Bison cannot deal with grammars that need more than 1 token of lookahead.
```
sentence: tall_student IS TALL | smart_student IS SMART
tall_student: YUNHAO | ZECHEN
smart_student: YUNHAO | YANJIA
```

When parsing sentence `YUNHAO IS TALL`, it cannot determine whether `YUNHAO` is `tall_student` or `smart_student` until it sees `TALL`. (2 tokens lookahead).

In contrast, the following grammar will work:
```
sentence: tall_student IS_TALL | smart_student IS_SMART
tall_student: YUNHAO | ZECHEN
smart_student: YUNHAO | YANJIA
```

* Bison creates the C program by plugging pieces into a standard skeleton file.
* Some bits of the skeleton have multiple versions depending on the options.

## Abstract Syntax Trees (AST)

* Parse tree: has a node for every rule used to parsed the input string.
* However, there are rules to manage grouping that adds no meaning to the program.
* AST is roughly a parse tree that omits the nodes for uninteresting nodes.
* After creating the AST, we can write the routines that "walk" the tree.

It is fine to use `char` to describe a token instead of explicitly defining it.
> Bison starts the numbers for named tokens at 258, so no collisions.

Use different symbols to set the precedence produces hard-to-maintain code.

Bison provides a clever way to describe the precedence separately from grammar rules.

```
exp: exp '+' exp { ... }
   | exp '-' exp { ... }
   | exp '*' exp { ... }
   | exp '/' exp { ... }
   | '|' exp     { ... }
   | '(' exp ')' { ... }
   | '-' exp     { ... }
   | NUM         { ... }
```

What is missing from the code above:
* Precedence: which operators execute first in an expression.
* Associativity: grouping of operators at the same precedence level.
  > group to left; group to right; do not group at all.

How to specify:
* Implicitly: using separate non-terminal symbols for each precedence level.
* Explicitly:
  ```
  %left '+' '-'
  %left '*' '/'
  %noassoc '|' UMINUS

  exp: ...
     | '-' exp %prec UMINUS { $$ = new_ast('M', NULL, $2); }
     ;
  ```
  > `%prec UMINUS` tells Bison to use the precedence of `UMINUS` for `-` in the rule.
  > When bison encounters a shift/reduce conflict, it consults the table of precedence.
  > It all the rules involved in the conflict have a precedence assigned, the conflict is solved.

Use precedence in only:
* expression grammars;
* resolve the "dangling else" conflict for if/then/else construct.