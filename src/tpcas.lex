%{
    #include "../src/tree.h"
    #include "../obj/tpcas.tab.h"
    int lineno = 1;
    int colno = 0;
%}

%option nounput
%option noinput
%option noyywrap
%x COM

%%
"/*"                            {colno += 2; BEGIN COM;}          /* Début d'un commentaire       */
<COM>"*/"                       BEGIN INITIAL;                    /* Fin d'un commentaire         */
<COM>.                          ;                                 /* Dans commentaire passe       */
<COM>\n                         ;                                 /* Dans commentaire passe       */
"//".*                          colno += 2;                       /* Commentaire on passe         */

if                              {colno += 2; return IF;}          /* Expression If                */
else                            {colno += 4; return ELSE;}        /* Expression Else              */
while                           {colno += 5; return WHILE;}       /* Expression While             */
return                          {colno += 6; return RETURN;}      /* Expression Return            */

int                           { strcpy(yylval.string, yytext); 
                                colno += 3;
                                return TYPE; }      /* Type de variable/fonction    */
char                          { strcpy(yylval.string, yytext); 
                                colno += 4;
                                return TYPE; }      /* Type de variable/fonction    */


void                          { strcpy(yylval.string, yytext);
                                colno += 4;
                                return VOID; }      /* Type void                    */

\'(.|\\n|\\t)\'               { strcpy(yylval.string, yytext);
                                colno += yyleng;
                                return CHARACTER; } /* Variable de type char        */

[0-9]+                        { yylval.num = atoi(yytext); 
                                colno += yyleng;
                                return NUM; }       /* Récupère nombre              */

[a-zA-Z_]*[a-zA-Z_0-9]*       { strcpy(yylval.string, yytext); 
                                colno += yyleng;
                                return IDENT; }     /* Nom de variable              */

==|!=                         { strcpy(yylval.string, yytext); 
                                colno += 2;
                                return EQ; }        /* Opérateur d'égalité          */
(<|>)                         { strcpy(yylval.string, yytext); 
                                colno += 1;
                                return ORDER; }     /* Opérateur de comparaison     */

(<=|>=)                      { strcpy(yylval.string, yytext); 
                                colno += 2;
                                return ORDER; }     /* Opérateur de comparaison     */

[!+-]                          { yylval.character = yytext[0]; 
                                colno += 1;
                                return ADDSUB; }    /* Opérateur binaire ou unaire  */

[*/%]                         { yylval.character = yytext[0]; 
                                colno += 1;
                                return DIVSTAR; }   /* Opérateur MUL, DIV, MODULO   */

&&                            { strcpy(yylval.string, yytext);
                                colno += 2;
                                return AND; }       /* Opérateur booléens           */
\|\|                          { strcpy(yylval.string, yytext); 
                                colno += 2;
                                return OR; }        /* Opérateur booléens           */

\n                            { lineno++;
                                colno = 0 ; }       /* Réinitialise à 0             */
[\t ]                           colno += yyleng;
[ ]+                            colno += yyleng;
.                             { colno++; 
                                return yytext[0]; }
%%