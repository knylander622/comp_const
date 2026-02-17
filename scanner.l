
/* definitions */

%{
#include <stdio.h>
#include <stdlib.h>
#include "tokendef.h"

 /* integers to track line and column numbers */
int scancol = 1;
int yycol = 1;
int scanlineno = 1;

 /* char pointer to pass error messages to driver.c */
char *yyerror;

 /* TODO: functions to update line and column numbers */
void updateCol();
void countLines();

 /* TODO: function to process a string literal */
int processString();

%}

newline         [\r]?[\n] //TODO
whitespace      [\t ]+ //TODO
integer         0|[1-9][0-9]* //TODO
character       //TODO

 /* String can contain any characters between the double quotes */
 /* other than a newline or unescaped doublequotes */
*/
string          //TODO


 /* If the end quote is not found in the same line the string is unterminated */
untermstring    //TODO

comment         //TODO
multlncomment   //TODO
untermcomment   //TODO

identifier      {letter}({letter}|{digit})* //TODO
illidentifier   {digit}+{letter}+ //TODO: regular expression for an illegal identifier

yylineno = 1;

%%

 /* rules */

 /* Keywords */
 /* TODO: Support all keywords in mC */

"if"	  { updateCol(); return KWD_IF; }
"else"	  { updateCol(); return KWD_ELSE; }
"while"	  { updateCol(); return KWD_WHILE; }
"int"	  { updateCol(); return KWD_INT; }
"string"  { updateCol(); return KWD_STRING; }
"char"	  { updateCol(); return KWD_CHAR; }
"return"  { updateCol(); return KWD_RETURN; }
"void"	  { updateCol(); return KWD_VOID; }

 /* Operators */
 /* TODO: Support all operators in mC */

"+"	  { updateCol(); return OPER_ADD; }
"*"	  { updateCol(); return OPER_MUL; }
"/"       { updateCol(); return OPER_DIV; }
"%"	  { updateCol(); return OPER_MOD; }
"<"	  { updateCol(); return OPER_LT; }
">"	  { updateCol(); return OPER_GT; }
"<="	  { updateCol(); return OPER_LTE; }
">="  	  { updateCol(); return OPER_GTE; }
"=="	  { updateCol(); return OPER_EQ; }
"!="	  { updateCol(); return OPER_NEQ; }
"="	  { updateCol(); return OPER_ASGN; }
"["	  { updateCol(); return LSQ_BRKT; }
"]"	  { updateCol(); return RSQ_BRKT; }
"{"	  { updateCol(); return LCRLY_BRKT; }
"}"	  { updateCol(); return RCRLY_BRKT; }
"("  	  { updateCol(); return LPAREN; }
")"	  { updateCol(); return RPAREN; }
","  	  { updateCol(); return COMMA; }
";"  	  { updateCol(); return SEMICLN; }
"@"       { updateCol(); return OPER_AT; }
"++"	  { updateCol(); return OPER_INC; }
"--"  	  { updateCol(); return OPER_DEC; }
"&&"	  { updateCol(); return OPER_AND; }
"||"	  { updateCol(); return OPER_OR; }
"!"	  { updateCol(); return OPER_NOT; }

 /* Identifiers */;
{identifier}	  { updateCol(); return ID; } //TODO
{illidentifier}   { updateCol(); return ILLEGAL_TOK; }//TODO

 /* Constants */;
{integer}         { updateCol(); return INTCONST; } //TODO
{integerlead0}    { updateCol(); return ILLEGAL_TOK; } //TODO: "Integers may not have leading zeros"
{character}       { updateCol(); return CHARCONST; } //TODO
{string}          { updateCol(); return processString(); }
{untermstring}    { updateCol(); yyerror = "Unterminated string"; return ERROR;}

 /* Comments */
{comment}         { updateCol(); }//TODO
{untermcomment} //TODO
{multlncomment} //TODO

 /* Other */
{newline}         { countLines(); }//TODO
{whitespace}      { updateCol(); }//TODO
.               {return ILLEGAL_TOK;}

%%

/* user routines */

/* TODO:
Implement this function to keep track of column numbers
*/
void updateCol(){
   yycol = scancol;
   ++scancol;
}

/* TODO:
Implement this function to keep track of line numbers
*/
void countLines(){
   yycol = scancol;
   scancol = 1;
   ++yylineno;
}


/* TODO:
Implement this function to
check for illegal escape sequences in string literals
and
convert valid escape sequences into escaped characters
(string[0] == '\\' and string[1] == 'n', then string[0] should be '\n')
*/
int processString(){
}
