default : 
	yacc -d compilerC.y
	lex compilerC.l
	gcc lex.yy.c y.tab.c -o compiler
	./compiler

para gerar o ficheiro y.output:
	yacc -d -v compilerC.y
	lex compilerC.l
	gcc lex.yy.c y.tab.c -o compiler
	./compiler