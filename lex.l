%{
#include <stdio.h>
#include "y.tab.h"
%}

%%

[ \t]*BLOCO[ \t]*_[a-zA-Z0-9][a-zA-Z0-9]*_     { return BLOCO_INICIO; }
[ \t]*FIM[ \t]*_[a-zA-Z0-9][a-zA-Z0-9]*_     { return BLOCO_FIM; }
[ \t]*NUMERO[ \t]*          { return TIPO_INTEIRO; }
[ \t]*CADEIA[ \t]*          { return TIPO_STRING; }
[ \t]*PRINT[ \t]*           { return PRINT; }
[ \t]*[a-zA-Z][a-zA-Z0-9]*[ \t]*   { yylval.string = strdup(yytext); return ID; }
[ \t]*[0-9]+[ \t]*          { yylval.number = atoi(yytext); return NUMERO; }
[ \t]*\"[^\"]*\"[ \t]*        { yylval.string = strdup(yytext); return STRING; }
=                           { return IGUAL; }
;                           { return FIM; }
,                           { return VIRGULA; }
\+                          { return MAIS; }
\n                          {  }
[ \t]+                      {  }


%%
