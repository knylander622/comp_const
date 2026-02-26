
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

newline         (\r?\n)
whitespace      [\t ]+
integer         0|[1-9][0-9]*
integerlead0    0[0-9]+
character       [^"\\\n?]
charconst       \'([^\'\\\n]|\\[nt\"\\\'])\'
letter          [a-z]|[A-Z]
escape          \\.

 /* String can contain any characters between the double quotes */
 /* other than a newline or unescaped doublequotes */

string          \"({character}|{escape})*\"
untermstring_eof    \"({character}|{escape})*

 /* If the end quote is not found in the same line the string is unterminated */
untermstring    \"({character}|{escape})*{newline}

comment         [/][/].*
multlncomment   "/*"([^*]|\*+[^*/]|\n)*\*+\/
untermcomment   "/*"([^*]|\*+[^*/]|\n)*

identifier      {letter}({letter}|{integer})*   
illidentifier   {integer}+{letter}+

yylineno = 1; 

%%

 /* rules */

 /* Keywords */
 /* TODO: Support all keywords in mC */

"if"      { updateCol(); return KWD_IF; }
"else"    { updateCol(); return KWD_ELSE; }
"while"   { updateCol(); return KWD_WHILE; }
"int"     { updateCol(); return KWD_INT; }
"string"  { updateCol(); return KWD_STRING; }
"char"    { updateCol(); return KWD_CHAR; }
"return"  { updateCol(); return KWD_RETURN; }
"void"    { updateCol(); return KWD_VOID; }

 /* Operators */
 /* TODO: Support all operators in mC */

"+"       { updateCol(); return OPER_ADD; }
"*"       { updateCol(); return OPER_MUL; }
"/"       { updateCol(); return OPER_DIV; }
"%"       { updateCol(); return OPER_MOD; }
"<"       { updateCol(); return OPER_LT; }
">"       { updateCol(); return OPER_GT; }
"<="      { updateCol(); return OPER_LTE; }
">="      { updateCol(); return OPER_GTE; }
"=="      { updateCol(); return OPER_EQ; }
"!="      { updateCol(); return OPER_NEQ; }
"="       { updateCol(); return OPER_ASGN; }
"["       { updateCol(); return LSQ_BRKT; }
"]"       { updateCol(); return RSQ_BRKT; }
"{"       { updateCol(); return LCRLY_BRKT; }
"}"       { updateCol(); return RCRLY_BRKT; }
"("       { updateCol(); return LPAREN; }
")"       { updateCol(); return RPAREN; }
","       { updateCol(); return COMMA; }
";"       { updateCol(); return SEMICLN; }
"@"       { updateCol(); return OPER_AT; }
"++"      { updateCol(); return OPER_INC; }
"--"      { updateCol(); return OPER_DEC; }
"&&"      { updateCol(); return OPER_AND; }
"||"      { updateCol(); return OPER_OR; }
"!"       { updateCol(); return OPER_NOT; }

 /* Identifiers */
{identifier}      { updateCol(); return ID; }
{illidentifier}   { updateCol(); return ILLEGAL_TOK; }

 /* Constants */
{integer}         { updateCol(); return INTCONST; }
{integerlead0}    { updateCol(); return ILLEGAL_TOK; }
{newline}         { countLines(); }
{whitespace}      { updateCol(); }
{charconst}       { updateCol(); return CHARCONST;}
{character}       { updateCol(); return CHARCONST; }
{string}          { return processString(); }
{untermstring} {
    int startCol  = scancol;

    yyerror = "String spans multiple lines";
    for(int i = 0; yytext[i] != '\0';i++){
        if(yytext[i] == '\n') countLines();
        else scancol++;
    }
    yycol = startCol;
    /* error_location = token_start */
    return ERROR;
}
{untermstring_eof} {
    yycol = scancol;                 /* opening quote col */
    yyerror = "Unterminated string constant";
    scancol += yyleng;
    return ERROR;
}

 /* Comments */
{comment}         { updateCol(); }
{multlncomment}   {
    for (int i = 0; yytext[i] != '\0'; i++) {
        if (yytext[i] == '\n') countLines();
        else updateCol();
    }
}
{untermcomment} {
    int startLine = yylineno;
    int startCol  = scancol;

    for (int i = 0; yytext[i] != '\0'; i++) {
        if (yytext[i] == '\n') countLines();
        else scancol++;
    }

    yylineno = startLine;
    yycol    = startCol;
    yyerror  = "Unterminated comment";
    return ERROR;
}

 /* Other */
.                 { updateCol(); return ILLEGAL_TOK;}

%%

/* user routines */

/* TODO:
Implement this function to keep track of column numbers
*/
void updateCol(){
   yycol = scancol;
   scancol += yyleng;
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
int processString() {
    int startCol = scancol;   /* column of opening " */
    int i = 1;                /* read index: skip opening quote */
    int out = 0;              /* write index: overwrite yytext with contents only */

    while (yytext[i] != '"' && yytext[i] != '\0') {
        if (yytext[i] == '\\') {
            int escCol = startCol + i + 1;   /* column of the '\' */

            i++;  /* move to escaped char */
            if (yytext[i] == '\0') {
                yycol = startCol;
                yyerror = "Unterminated string";
                scancol += yyleng;
                return ERROR;
            }

            if (yytext[i] == 'n')      { yytext[out++] = '\n'; i++; }
            else if (yytext[i] == 't') { yytext[out++] = '\t'; i++; }
            else if (yytext[i] == '\\'){ yytext[out++] = '\\'; i++; }
            else if (yytext[i] == '"') { yytext[out++] = '"';  i++; }
            else {
                yycol = escCol;
                yyerror = "Unrecognized escape character in String";
                scancol += yyleng;
                return ERROR;
            }
        } else {
            yytext[out++] = yytext[i++];
        }
    }

    if (yytext[i] != '"') {
        yycol = startCol;
        yyerror = "Unterminated string";
        scancol += yyleng;
        return ERROR;
    }

    yytext[out] = '\0';  /* yytext = contents */
    yycol = startCol;    /* token start @ opening quote */
    scancol += yyleng;   /* advance past full original lex */
    return STRCONST;
}
