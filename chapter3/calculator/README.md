# Advanced Desktop Calculator

## Operators

* Arithmetic:
  * `+` add
  * `-` subtract, negate
  * `*` multiply
  * `/` divide
* Comparative:
  * `=` equal
  * `<` less
  * `>` greater
* Logical:
  * `&` and
  * `|` or
  * `!` not
* Other:
  * `()` round brackets
  * `{}` curly brackets
  * `:=` assign
  * `,` comma
  * `;` semicolon

## Keywords

* `if`
  ```
  if a < b {
      print(a);
  }
  ```
* `else`
  ```
  if a < b {
      print(a);
  } else {
      print(b);
  }
  ```
* `while`
  ```
  while x < 10 {
      print(x);
      x := x + 1;
  }
  ```
* `do`
  ```
  do {
      print(x);
      x := x + 1;
  } while x < 10;
  ```
* `let`
  ```
  let x = 12;
  ```

## Build-in Functions

* `abs` absolute value
* `round` round to nearest
* `ceil` round up
* `floor` round down
* `sqrt` square root
* `pow` power
* `log` natural logarithm
* `print` print number