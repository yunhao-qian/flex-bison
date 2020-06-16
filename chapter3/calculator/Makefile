H_SRC=$(shell echo src/*.h)
C_SRC=$(shell echo src/*.c)

bin/calc: bin/calc.lex.c bin/calc.tab.c $(H_SRC) $(C_SRC)
	gcc -Isrc -g -o $@ $^ -lm
bin/calc.lex.c: src/calc.l dir
	flex -o$@ $<
bin/calc.tab.c: src/calc.y dir
	bison -b bin/calc $< -d
.PHONY: dir clean
dir:
	mkdir -p bin
clean:
	rm -rf bin
