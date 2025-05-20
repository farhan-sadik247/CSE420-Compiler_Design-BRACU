%option noyywrap

%{
#include<bits/stdc++.h>
using namespace std;

ofstream outlog; //output filestream for log file

string loglist = ""; //list of tokens along with line numbers

// define necessary c++ variables and functions here (if any)
int lines = 1;

%}

/* Regular Definitions */

delim	 [ \t\v\r]

/* write regular expressions for whitespace and newline */
ws " "

newline  "\n"

letter_	 [A-Za-z_]
digit	 [0-9]

/* write regular expressions for id, float and integers */
id {letter_}({letter_}|{digit})*
float {digit}+"."{digit}+
int {digit}+


%%

{ws}		{ /* ignore whitespace */ }
{newline}	{ /* do necessary bookkeeping (line number tracking etc.) */
                lines++;
                loglist="Line no "+to_string(lines)+": Newline found"+"\n"+"\n";
                outlog<<loglist;
            }

{id}       {
                symbol_info *s = new symbol_info((string)yytext,"ID");
                yylval = (YYSTYPE)s;
                loglist="Line no "+to_string(lines)+": Token <ID> Lexeme "+yytext+" found"+"\n"+"\n";
			    outlog<<loglist;
                return ID;
            }

{float}     {
                symbol_info *s = new symbol_info((string)yytext,"FLOAT");
                yylval = (YYSTYPE)s;
                loglist="Line no "+to_string(lines)+": Token <FLOAT> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                return FLOAT;
            }

{int}       {
                symbol_info *s = new symbol_info((string)yytext,"INT");
                yylval = (YYSTYPE)s;
                loglist="Line no "+to_string(lines)+": Token <INT> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                return INT;
            }

if          { 
                loglist="Line no "+to_string(lines)+": Token <IF> Lexeme "+yytext+" found"+"\n"+"\n";
			    outlog<<loglist;
                return IF; }

else        { 
                loglist="Line no "+to_string(lines)+": Token <ELSE> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                return ELSE; }

for         { 
                loglist="Line no "+to_string(lines)+": Token <FOR> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                return FOR; }

while       { 
                loglist="Line no "+to_string(lines)+": Token <WHILE> Lexeme "+yytext+" found"+"\n"+"\n";
			    outlog<<loglist; 
                return WHILE; }

do          { 
                loglist="Line no "+to_string(lines)+": Token <DO> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist; 
                return DO; }

break       { 
                loglist="Line no "+to_string(lines)+": Token <BREAK> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist; 
                return BREAK; }

int         { 
                loglist="Line no "+to_string(lines)+": Token <INT> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist; 
                return INT; }

char        { 
                loglist="Line no "+to_string(lines)+": Token <CHAR> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist; 
                return CHAR; }

float       {
                loglist="Line no "+to_string(lines)+": Token <FLOAT> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist; 
                return FLOAT; }

void        {
                loglist="Line no "+to_string(lines)+": Token <VOID> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist; 
                return VOID; }

double      {
                loglist="Line no "+to_string(lines)+": Token <DOUBLE> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist; 
                return DOUBLE; }

return      {
                loglist="Line no "+to_string(lines)+": Token <RETURN> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist; 
                return RETURN; }

switch      {
                loglist="Line no "+to_string(lines)+": Token <SWITCH> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist; 
                return SWITCH; }

case        {
                loglist="Line no "+to_string(lines)+": Token <CASE> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist; 
                return CASE; }

default     {
                loglist="Line no "+to_string(lines)+": Token <DEFAULT> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist; 
                return DEFAULT; }

continue    {
                loglist="Line no "+to_string(lines)+": Token <CONTINUE> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist; 
                return CONTINUE; }

goto        {
                loglist="Line no "+to_string(lines)+": Token <GOTO> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist; 
                return GOTO; }

printf      {
                loglist="Line no "+to_string(lines)+": Token <PRINTF> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist; 
                return PRINTF; }

"+"|"-"	    {
                symbol_info *s = new symbol_info((string)yytext,"ADDOP");
                yylval = (YYSTYPE)s;
                loglist="Line no "+to_string(lines)+": Token <ADDOP> Lexeme "+yytext+" found"+"\n"+"\n";
			    outlog<<loglist;
                return ADDOP;
		    }

"*"|"/"|"%"	{
                symbol_info *s = new symbol_info((string)yytext,"MULOP");
                yylval = (YYSTYPE)s;
                loglist="Line no "+to_string(lines)+": Token <MULOP> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                return MULOP;
            }

"++"|"--"	{
                symbol_info *s = new symbol_info((string)yytext,"INCOP");
                yylval = (YYSTYPE)s;
                loglist="Line no "+to_string(lines)+": Token <INCOP> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                return INCOP;
            }

"<"|">"|"=="|"!="|"<="|">="	{
                symbol_info *s = new symbol_info((string)yytext,"RELOP");
                yylval = (YYSTYPE)s;
                loglist="Line no "+to_string(lines)+": Token <RELOP> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                return RELOP;
            }

"="	        {
                symbol_info *s = new symbol_info((string)yytext,"ASSIGNOP");
                yylval = (YYSTYPE)s;
                loglist="Line no "+to_string
            }

"&&"|"||"	{
                symbol_info *s = new symbol_info((string)yytext,"LOGICOP");
                yylval = (YYSTYPE)s;
                loglist="Line no "+to_string(lines)+": Token <LOGICOP> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                return LOGICOP;
            }

"!"	        {
                symbol_info *s = new symbol_info((string)yytext,"NOT");
                yylval = (YYSTYPE)s;
                loglist="Line no "+to_string(lines)+": Token <NOT> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                return NOT;
            }

"("	        {
                symbol_info *s = new symbol_info((string)yytext,"LPAREN");
                yylval = (YYSTYPE)s;
                loglist="Line no "+to_string(lines)+": Token <LPAREN> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                return LPAREN;
            }

")"	        {
                symbol_info *s = new symbol_info((string)yytext,"RPAREN");
                yylval = (YYSTYPE)s;
                loglist="Line no "+to_string(lines)+": Token <RPAREN> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                return RPAREN;
            }

"{"	        {
                symbol_info *s = new symbol_info((string)yytext,"LBRACE");
                yylval = (YYSTYPE)s;
                loglist="Line no "+to_string(lines)+": Token <LBRACE> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                return LBRACE;
            }

"}"	        {
                symbol_info *s = new symbol_info((string)yytext,"RBRACE");
                yylval = (YYSTYPE)s;
                loglist="Line no "+to_string(lines)+": Token <RBRACE> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                return RBRACE;
            }

"["          {
                symbol_info *s = new symbol_info((string)yytext,"LTHIRD");
                yylval = (YYSTYPE)s;
                loglist="Line no "+to_string(lines)+": Token <LTHIRD> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                return LTHIRD;
            }

"]"          {
                symbol_info *s = new symbol_info((string)yytext,"RTHIRD");
                yylval = (YYSTYPE)s;
                loglist="Line no "+to_string(lines)+": Token <RTHIRD> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                return RTHIRD;
            }

","         { 
                loglist="Line no "+to_string(lines)+": Token <COMMA> Lexeme "+yytext+" found"+"\n"+"\n";
			    outlog<<loglist;               
                return COMMA; }

";"         {
                loglist="Line no "+to_string(lines)+": Token <SEMICOLON> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist; 
                return SEMICOLON; }

":"         {
                loglist="Line no "+to_string(lines)+": Token <COLON> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist; 
                return COLON; 
            }

%%