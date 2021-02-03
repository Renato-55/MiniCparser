%{
#include <stdio.h>
#include "y.tab.h"

int linenum = 1;
%}
%option noyywrap
digit	([0-9])
alpha   [A-Za-z]
%%


"printf"        {	return(TOK_PRINTID);}
"main()"        {	return(TOK_MAIN);}
"struct"		{	return TOK_STRUCT;}
"while"			{	return(TOK_WHILE);}
"for"			{	return(TOK_FOR);}
"if"			{	return(TOK_IF);}
"else"			{	return(TOK_ELSE);}
"{"        		{	return(TOK_CHA_DIR);}
"}"        		{	return(TOK_CHA_ESQ);}
"("				{	return(TOK_PAR_CUR_ESQ);}	
")"				{	return(TOK_PAR_CUR_DIR);}
"int"			{	return(TOK_INT);}
"float"			{	return(TOK_FLOAT);}
"char"			{	return(TOK_CHAR);}
"void"			{	return(TOK_VOID);}
"="				{	return(TOK_EQ);}
";"				{	return(TOK_SEMICOLON);	}
"_"				{	return(TOK_UNDERSCORE);}
"+"				{	return(TOK_ADD);	}
"-"				{	return(TOK_SUB);	}
"*"				{	return(TOK_MUL);	}
"/"				{	return(TOK_DIV);	}
"<=" 			{	return(TOK_LOWER_EQUAL);	}
">=" 			{	return(TOK_GREATER_EQUAL);	}
"==" 			{	return(TOK_EQUAL_EQUAL);	}
"!=" 			{	return(TOK_DIFERENT);	}
"<"  			{	return(TOK_GREATER);	}
">"  			{	return(TOK_LOWER);	}

"/*"(.*\n)*.*"*/"	{   }
{digit}+				{
							yylval.variable.charVar = ' ';
							yylval.variable.intVar = atoi(yytext); 
							yylval.variable.floatVar = 0; 
							return TOK_NUM; 
						}

{digit}+[.]{digit}      {
							yylval.variable.charVar = ' ';
							yylval.variable.intVar = 0; 
							yylval.variable.floatVar = atof(yytext); 
							return TOK_FNUM; 
						}

\'.\'					{	
							yylval.variable.charVar = yytext[1];
							yylval.variable.intVar = 0; 
							yylval.variable.floatVar = 0; 
							return TOK_ONE_CHAR; 
						}
						
\".*\"					{
						sscanf(yytext, "%[^\n]s",yylval.str); return(TOK_STR);
						}

[a-z][A-Za-z0-9]*   {sscanf(yytext, "%s", yylval.name); return(TOK_IDENT);}
([0-9])[A-Za-z0-9]* {sscanf(yytext, "%s", yylval.name); return(TOK_IDENT_ERR);}	

"#include "[A-Za-z]+".h"		{  return TOK_INCLUDE;}







[\n] 	{linenum++;}
[" "] 	{}
[\t] 	{}





%%

/* Outra regra para reconehcer o resto dos tokens
.	{
		printf("Invalid character '%c', ignored\n", 
		yytext[0]);
	}
*/