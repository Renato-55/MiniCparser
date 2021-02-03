%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

extern int linenum;
int yylex();
int search(char name[]);
void insert(char name[], int type, char value[]);
void printTab();
int yyerror(char *s);
void yyerror2(int type, char *s, char b[]);
void insertVal(char value[], int posi);
void valAssign(int modifier, char s1[], char s3[]);

struct symtab{
	char name[20];
	int type; // 1 is int, 2 is float, 3 for char , 4 for struct
	char value[20];
};

struct symtab tab[20];
int ptr = 0;

%}
%name parser_name
%token  TOK_SEMICOLON 
		TOK_ADD TOK_SUB TOK_MUL TOK_DIV TOK_EQ
	    TOK_INT TOK_FLOAT TOK_IDENT
		TOK_PRINTID TOK_MAIN TOK_CHA_DIR TOK_CHA_ESQ
		TOK_IDENT_ERR
		TOK_INCLUDE TOK_STRUCT
		TOK_WHILE TOK_FOR TOK_IF TOK_ELSE
		TOK_PAR_CUR_ESQ TOK_PAR_CUR_DIR TOK_LOWER_EQUAL TOK_GREATER_EQUAL TOK_EQUAL_EQUAL TOK_DIFERENT TOK_GREATER TOK_LOWER TOK_STR
		TOK_CHAR TOK_ONE_CHAR TOK_VOID TOK_UNDERSCORE 



%union{
	char name[20];
    int int_val;

	struct strVariable{
		int intVar;
		float floatVar;
		char charVar;
	
	}variable;
	
	char str[200];
 
}
%token <variable> TOK_NUM TOK_FNUM
%type <variable> expr RAW TOK_ONE_CHAR exprBol
%type <name> TOK_IDENT
%type <name> TOK_IDENT_ERR
%type <str> TOK_STR 
%left TOK_ADD TOK_SUB
%left TOK_MUL TOK_DIV

%%
prog: struct | TOK_INCLUDE prog
;
struct: main | structdefs struct
;
structdefs : TOK_STRUCT TOK_CHA_DIR vardefs TOK_CHA_ESQ TOK_IDENT TOK_SEMICOLON {
		
		int flag;
		char *t;
	    flag = search($5);

		if(flag == -1){
			insert($5, 4, "0");
		}else{
			t = "Struct identifier already defined - ";
			yyerror2(3,t, $5);
		}									
											
	}
;
main: TOK_VOID TOK_MAIN TOK_CHA_DIR stmts TOK_CHA_ESQ
	 |
	TOK_INT TOK_MAIN TOK_CHA_DIR stmts TOK_CHA_ESQ
	|
	{
		char *t ="Parsing Error";
		yyerror2(3,t,"");
	}
;
stmts: 
	| stmt TOK_SEMICOLON stmts  
	| ciclesAndOther stmts 
	| vardef TOK_SEMICOLON stmts
	
;
vardefs:
	| vardef TOK_SEMICOLON vardefs
;
vardef:
	  TOK_INT TOK_IDENT {

	    int flag;
		char *t;
	    flag = search($2);

		if(flag == -1){
			insert($2, 1, "0");
		}else{
			t = "Identifier already defined - ";
			yyerror2(3,t, $2);
		}

	  }
	| TOK_INT TOK_IDENT_ERR
	  {
		char *t ="Invalid Identifier - ";
		yyerror2(3,t,$2);
	  }

	| TOK_FLOAT TOK_IDENT {

	    int flag;
		char *t;
	    flag = search($2);

		if(flag == -1){
			insert($2, 2, "0.0");
		}else{
			t = "Identifier already defined - ";
			yyerror2(3,t,$2);
		}

	  }
	| TOK_FLOAT TOK_IDENT_ERR
	  {
		char *t ="Invalid Identifier - ";
		yyerror2(3,t,$2);
	  }
	| TOK_CHAR TOK_IDENT 
	{
	    int flag;
		char *t;
	    flag = search($2);

		if(flag == -1){
			insert($2, 3, " ");
		}else{
			t = "Identifier already defined - ";
			yyerror2(3,t,$2);
		}

	}
	| TOK_CHAR TOK_IDENT_ERR
	  {
		char *t ="Invalid Identifier - ";
		yyerror2(3,t,$2);
	  }
	|
;
ciclesAndOther: whileCicle | ifCond | forCicle
;
whileCicle: TOK_WHILE TOK_PAR_CUR_ESQ exprBol TOK_PAR_CUR_DIR TOK_CHA_DIR stmts TOK_CHA_ESQ
;
ifCond: TOK_IF TOK_PAR_CUR_ESQ exprBol TOK_PAR_CUR_DIR 
		TOK_CHA_DIR stmts TOK_CHA_ESQ
		|
		TOK_IF TOK_PAR_CUR_ESQ exprBol TOK_PAR_CUR_DIR 
		TOK_CHA_DIR stmts TOK_CHA_ESQ TOK_ELSE TOK_CHA_DIR stmts TOK_CHA_ESQ	
;

forCicle: 
		  TOK_FOR TOK_PAR_CUR_ESQ
		  TOK_IDENT TOK_EQ TOK_IDENT TOK_SEMICOLON 
		  exprBol TOK_SEMICOLON
		  TOK_IDENT TOK_ADD TOK_ADD TOK_PAR_CUR_DIR TOK_CHA_DIR stmts TOK_CHA_ESQ 
		  | 
		  TOK_FOR TOK_PAR_CUR_ESQ
		  TOK_IDENT TOK_EQ TOK_NUM TOK_SEMICOLON   
		  exprBol TOK_SEMICOLON
		  TOK_IDENT TOK_ADD TOK_ADD TOK_PAR_CUR_DIR TOK_CHA_DIR stmts TOK_CHA_ESQ

;
exprBol:
		TOK_IDENT TOK_DIFERENT expr {
		int flag;
		char *t;
		int type;
	    flag = search($1);
		struct strVariable temp2;
		
		temp2.floatVar=0.0;
		temp2.charVar=' ';
		
		if(flag == -1){
			t = "Identifier not defined - ";
			yyerror2(3,t,$1);
		}else{
			type=tab[flag].type;
			
			if(type==1){ // int var
				if( atoi(tab[flag].value) != $3.intVar){
					temp2.intVar = 1; // printf("%d\n",temp2.intVar);
				}else{
					temp2.intVar = -1;  //  printf("%d\n",temp2.intVar);
				}
			} else if (type==2){ // float var
				if( atof(tab[flag].value) != $3.floatVar){
					temp2.intVar = 1;  // printf("%d\n",temp2.intVar);
				}else{
					temp2.intVar = -1;  // printf("%d\n",temp2.intVar);
				}
			}
			$$ = temp2;
		}
	  }
		|
	   TOK_IDENT TOK_EQUAL_EQUAL expr {
		int flag;
		char *t;
		int type;
	    flag = search($1);
		struct strVariable temp2;
		
		temp2.floatVar=0.0;
		temp2.charVar=' ';
		
		if(flag == -1){
			t = "Identifier not defined - ";
			yyerror2(3,t,$1);
		}else{
			type=tab[flag].type;
			
			if(type==1){ // int var
				if( atoi(tab[flag].value) == $3.intVar){
					temp2.intVar = 1; // printf("%d\n",temp2.intVar);
				}else{
					temp2.intVar = -1;  //  printf("%d\n",temp2.intVar);
				}
			} else if (type==2){ // float var
				if( atof(tab[flag].value) == $3.floatVar){
					temp2.intVar = 1;  // printf("%d\n",temp2.intVar);
				}else{
					temp2.intVar = -1;  // printf("%d\n",temp2.intVar);
				}
			}
			$$ = temp2;
		}
	  }
	  | TOK_IDENT TOK_LOWER_EQUAL expr {
		int flag;
		char *t;
		int type;
	    flag = search($1);
		struct strVariable temp2;
		
		temp2.floatVar=0.0;
		temp2.charVar=' ';
		
		if(flag == -1){
			t = "Identifier not defined - ";
			yyerror2(1,t,$1);
		}else{
			type=tab[flag].type;
			
			if(type==1){ // int var
				if( atoi(tab[flag].value) <= $3.intVar){
					temp2.intVar = 1; //  printf("%d\n",temp2.intVar);
				}else{
					temp2.intVar = -1; //  printf("%d\n",temp2.intVar);
				}
			} else if (type==2){ // float var
				if( atof(tab[flag].value) <= $3.floatVar){
					temp2.intVar = 1; //  printf("%d\n",temp2.intVar);
				}else{
					temp2.intVar = -1;  // printf("%d\n",temp2.intVar);
				}
			}
			$$ = temp2;
		}
	  }
	  | TOK_IDENT TOK_LOWER expr {
		int flag;
		char *t;
		int type;
	    flag = search($1);
		struct strVariable temp2;
		
		temp2.floatVar=0.0;
		temp2.charVar=' ';
		
		if(flag == -1){
			t = "Identifier not defined - ";
			yyerror2(1,t,$1);
		}else{
			type=tab[flag].type;
			
			if(type==1){ // int var
				if( atoi(tab[flag].value) < $3.intVar){
					temp2.intVar = 1; //  printf("%d\n",temp2.intVar);
				}else{
					temp2.intVar = -1; //  printf("%d\n",temp2.intVar);
				}
			} else if (type==2){ // float var
				if( atof(tab[flag].value) < $3.floatVar){
					temp2.intVar = 1; //  printf("%d\n",temp2.intVar);
				}else{
					temp2.intVar = -1; //  printf("%d\n",temp2.intVar);
				}
			}
			$$ = temp2;
		}
	  }
	  | TOK_IDENT TOK_GREATER_EQUAL expr{
		int flag;
		char *t;
		int type;
	    flag = search($1);
		struct strVariable temp2;
		
		temp2.floatVar=0.0;
		temp2.charVar=' ';
		
		if(flag == -1){
			t = "Identifier not defined - ";
			yyerror2(1,t,$1);
		}else{
			type=tab[flag].type;
			
			if(type==1){ // int var
				if( atoi(tab[flag].value) >= $3.intVar){
					temp2.intVar = 1;  // printf("%d\n",temp2.intVar);
				}else{
					temp2.intVar = -1; //  printf("%d\n",temp2.intVar);
				}
			} else if (type==2){ // float var
				if( atof(tab[flag].value) >= $3.floatVar){
					temp2.intVar = 1; // printf("%d\n",temp2.intVar);
				}else{
					temp2.intVar = -1; //  printf("%d\n",temp2.intVar);
				}
			}
			$$ = temp2;
		}
	  }
	  | TOK_IDENT TOK_GREATER expr{
		int flag;
		char *t;
		int type;
	    flag = search($1);
		struct strVariable temp2;
		
		temp2.floatVar=0.0;
		temp2.charVar=' ';
		
		if(flag == -1){
			t = "Identifier not defined - ";
			yyerror2(1,t,$1);
		}else{
			type=tab[flag].type;
			
			if(type==1){ // int var
				if( atoi(tab[flag].value) > $3.intVar){
					temp2.intVar = 1; //  printf("%d\n",temp2.intVar);
				}else{
					temp2.intVar = -1; //  printf("%d\n",temp2.intVar);
				}
			} else if (type==2){ // float var
				if( atof(tab[flag].value) > $3.floatVar){
					temp2.intVar = 1; //  printf("%d\n",temp2.intVar);
				}else{
					temp2.intVar = -1; //  printf("%d\n",temp2.intVar);
				}
			}
			$$ = temp2;
		}
	  }
;

stmt:
	TOK_IDENT TOK_EQ expr
	  {
		int modifier;
		char val[15];
		if($3.intVar != 0) {
			modifier = 1;
			sprintf(val, "%d", $3.intVar);
		}else if($3.floatVar != 0){
			modifier = 2;
			sprintf(val, "%f", $3.floatVar);
		} else if ($3.charVar != ' '){
			modifier = 3;
			sprintf(val, "%c", $3.charVar);
		}
		valAssign(modifier, $1, val);
	  } 
	| TOK_IDENT TOK_EQ TOK_ONE_CHAR
	{
		int modifier;
		char val[15];
		if($3.intVar != 0) {
			modifier = 1;
			sprintf(val, "%d", $3.intVar);
		}else if($3.floatVar != 0){
			modifier = 2;
			sprintf(val, "%f", $3.floatVar);
		} else if ($3.charVar != ' '){
			modifier = 3;
			sprintf(val, "%c", $3.charVar);
		}
		valAssign(modifier, $1, val);
	}
	| TOK_PRINTID TOK_PAR_CUR_ESQ TOK_IDENT TOK_PAR_CUR_DIR
	  {
		//todo change print to file
		int flag;
		char *t;
	    flag = search($3);

		if(flag == -1){
			t = "Identifier not defined - ";
			yyerror2(3,t, $3);
		}else{
			printf("%s\n", tab[flag].value);
		}
	  }
	|
	TOK_PRINTID TOK_PAR_CUR_ESQ TOK_UNDERSCORE expr TOK_UNDERSCORE TOK_PAR_CUR_DIR
	{
		if($4.intVar != 0){
			printf("%d\n", $4.intVar);
		} else if ($4.charVar != ' ' ) {
			printf("%c\n", $4.charVar);
		} else {
			printf("%f\n", $4.floatVar);
		} 
	}
	| TOK_PRINTID TOK_PAR_CUR_ESQ TOK_STR TOK_PAR_CUR_DIR 
	{
		printf("%s\n",$3);
	}
;


expr:
	expr TOK_ADD expr
	  {
		struct strVariable temp2;

		int flag;
		if($1.intVar != 0 && $3.intVar != 0) {
			temp2.floatVar = 0;
			temp2.intVar = $1.intVar + $3.intVar;
		}else if($1.floatVar != 0 && $3.floatVar != 0) {
			temp2.intVar = 0;
			temp2.floatVar = $1.floatVar + $3.floatVar;
		}else {
			char *t = "Type mismatch";
			yyerror2(3,t, "");
		}
		
		$$ = temp2;

	  }
	|
	expr TOK_DIV expr
	  {
		struct strVariable temp;

		int flag;
		if($1.intVar != 0 && $3.intVar != 0) {
			temp.floatVar = 0;
			temp.intVar = $1.intVar / $3.intVar;
		}else if($1.floatVar != 0 && $3.floatVar != 0) {
			temp.intVar = 0;
			temp.floatVar = $1.floatVar / $3.floatVar;
		}else {
			char *t = "Type mismatch";
			yyerror2(3,t, "");
		}
		
		$$ = temp;
	  }
	| expr TOK_SUB expr
	  {
		struct strVariable temp2;

		int flag;
		if($1.intVar != 0 && $3.intVar != 0) {
			temp2.floatVar = 0;
			temp2.intVar = $1.intVar - $3.intVar;
		}else if($1.floatVar != 0 && $3.floatVar != 0) {
			temp2.intVar = 0;
			temp2.floatVar = $1.floatVar - $3.floatVar;
		}else {
			char *t = "Type mismatch";
			yyerror2(3,t, "");
		}
		
		$$ = temp2;

	  }
	| expr TOK_MUL expr
	  {
		//$$ = $1 * $3;
		
		struct strVariable temp;

		int flag;
		if($1.intVar != 0 && $3.intVar != 0) {
			temp.floatVar = 0;
			temp.intVar = $1.intVar * $3.intVar;
		}else if($1.floatVar != 0 && $3.floatVar != 0) {
			temp.intVar = 0;
			temp.floatVar = $1.floatVar * $3.floatVar;
		}else {
			char *t = "Type mismatch";
			yyerror2(3,t, "");
		}
		
		$$ = temp;
	  }
	| TOK_IDENT
	  {
		int flag;
		char *t;
	    flag = search($1);
		
		struct strVariable temp;

		if(flag == -1){
			t = "Identifier not defined - ";
			yyerror2(3,t, $1);
		}else{
			if(tab[flag].type == 1){
				temp.intVar = atoi(tab[flag].value);
				temp.floatVar = 0;
			}
			else {
				temp.intVar = 0;
				temp.floatVar = atof(tab[flag].value);
			}
		}
		
		$$ = temp;
	  }
	| RAW
;

RAW:
	TOK_NUM
	{
		$$ = $1;
	}
	| TOK_FNUM
	{
		$$ = $1;
	}
;



%%


void valAssign(int modifier, char s1[], char s3[]){
	int flag,flag2 = 0;
	char temp[20];

	flag = search(s1);

	if(flag == -1){
		char *t ="Identifier Not present - ";
		yyerror2(3,t,s1);
	}else{
		switch(modifier){
			case 1:
				if(tab[flag].type == 1) flag2 = 1;
				break;

			case 2:
				if(tab[flag].type == 2) flag2 = 1;
				break;
			case 3:
				if(tab[flag].type == 3) flag2 = 1;
			;
		}
		if(flag2 == 1){
			insertVal(s3, flag);
		}else{
			char *t ="Wrong Type Error - ";
			yyerror2(3,t,s3);
		}
	}
}

int yyerror(char *s)
{
	printf("Syntax Error on line %d\n%s\n",linenum, s);
	return 0;
}

void yyerror2(int type, char *s, char b[])
{
	//todo change print to file
	switch(type){
		case 1:
			printf("Syntax Error on line - %d\n%s\n",linenum, s);
			break;
		case 2:
			printf("Lexical Error on line - %d: %s\n",linenum, s);
			break;
		case 3:
			printf("Line - %d: %s%s\n",linenum, s, b);
			break;
	}

	exit(0);
}

int search(char name[]){

	int i;
	int flag = -1;

	for(i = 0; i < ptr; i++){
		if(strcmp(tab[i].name, name) == 0){
			flag = i;
			break;
		}
	}

	return flag;

}

void insert(char name[], int type, char value[]){

	strcpy(tab[ptr].name, name);
	strcpy(tab[ptr].value, value);
	tab[ptr].type = type;

	ptr++;

	printTab();
}

void insertVal(char value[], int posi){

	strcpy(tab[posi].value, value);

	printTab();

}

void printTab(){

	int i;

	for(i = 0; i < ptr; i++){

	//use for testing
		/*printf("Name - %s, value - %s, type - ", tab[i].name, tab[i].value);
		if(tab[i].type == 1) printf("int\n");
		else if(tab[i].type == 2) printf("float\n");*/
	}
}

int main()
{
	//todo remove clear
    system("clear");
	extern FILE *yyin, *yyout; 
    char *file[] = {"testeIf.txt","testeFor.txt","testeProf.txt","testeWhile.txt","testeStruct.txt","testeInclude.txt","testeErrorId.txt","testeSytaxeError.txt"};
	
	int i=0;
	int op=-1;
	do{
	system("clear");
	for(i=0;i<8;i++){
		printf("Ficheiro %d - %s\n",i+1,file[i]);
	}
	printf("\nEscolha um ficheiro para abrir: ");
	scanf("%d",&op);
	}while (op>8 || op<0);
	
	op = op -1;
	system("clear");
	printf("Ficheiro numero %d aberto: %s \n\n",op+1,file[op]);
	
    yyin = fopen(file[op], "r"); 
	if( yyin == NULL) {
		fprintf(stderr,"Ficheiro não aberto");
		exit(1);
	}	
    yyparse();
	
	
	
    return 0;
}