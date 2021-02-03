default : 
	yacc -d compilerC.y
	lex compilerC.l
	gcc lex.yy.c y.tab.c -o compiler
	./compiler

Generate y.output file :
	yacc -d -v compilerC.y
	lex compilerC.l
	gcc lex.yy.c y.tab.c -o compiler
	./compiler
