a.out: lex.yy.c
	gcc lex.yy.c -lfl

lex.yy.c: fb2-5.l
	flex fb2-5.l

clean:
	rm -f a.out lex.yy.c 
