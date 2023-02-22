%{
    #include "../src/tree.h"
    #include "../obj/tpcas.tab.h"

    #include <stdio.h>
    #include <string.h>
    #include <getopt.h>

    int yylex(void);
    int yyerror(char *);
    extern int lineno;
    extern int colno;
    extern char* yytext;
    struct Node* arbre;
%}

%token IF ELSE WHILE RETURN
%expect 1

%union {
    Node* node;

    char string[64];
    char character;
    int num;
}

%token <string> IDENT TYPE VOID CHARACTER OR AND EQ ORDER
%token <character> ADDSUB DIVSTAR
%token <num> NUM

%type <node> Prog DeclVarsGlobale DeclVarsLocale InitVarsLocale
            Declarateurs DeclFoncts DeclFonct EnTeteFonct
            Parametres ListTypVar Corps SuiteInstr Instr Exp
            TB FB M E T F LValue Arguments ListExp;

%%
Prog:  DeclVarsGlobale DeclFoncts               { $$ = makeNode(Prog);
                                                       arbre = $$;
                                                       addChild($$, $1);
                                                       
                                                       Node* fonctions = makeNode(DeclFoncts);
                                                       addChild($$, fonctions);
                                                       addChild(fonctions, $2);
                                                }
    ;
DeclVarsGlobale:
       DeclVarsGlobale TYPE Declarateurs ';'    { $$ = $1;
                                                       Node* pereNode = makeNode(DeclVarsGlobale);
                                                       addChild($$, pereNode);

                                                       Node* typeNode =  makeDataStringNode(Type, $2);
                                                       addChild(pereNode, typeNode);
                                                       addChild(typeNode, $3);
                                                }
    |                                           { $$ = makeNode(DeclVarsGlobale); }
    ;
DeclVarsLocale:
       DeclVarsLocale TYPE InitVarsLocale ';'   { $$ = $1;
                                                       Node* pereNode = makeNode(DeclVarsLocale);
                                                       addChild($$, pereNode);

                                                       Node* typeNode =  makeDataStringNode(Type, $2);
                                                       addChild(pereNode, typeNode);
                                                       addChild(typeNode, $3);
                                                }
    |                                           {$$ = makeNode(DeclVarsLocale); }
    ;
InitVarsLocale:
       IDENT                                    { $$ = makeDataStringNode(Ident, $1); }
    |  IDENT ',' InitVarsLocale                 { $$ = makeDataStringNode(Ident, $1);
                                                       addSibling($$, $3);
                                                }
    |  IDENT '=' Exp InitVarsLocale             { $$ = makeNode(Assign);
                                                       Node* identNode = makeDataStringNode(Ident, $1);
                                                       
                                                       addChild($$, identNode);
                                                       addChild($$, $3);
                                                       addSibling($$, $4);
                                                }
    |  IDENT '=' Exp                            { $$ = makeNode(Assign);
                                                       Node* identNode = makeDataStringNode(Ident, $1);
                                                       
                                                       addChild($$, identNode);
                                                       addChild($$, $3);
                                                }
    |  ',' InitVarsLocale                       { $$ = $2; }
    ;
Declarateurs:
       Declarateurs ',' IDENT                   { $$ = $1;
                                                       addSibling($$, makeDataStringNode(Ident, $3));
                                                }
    |  IDENT                                    { $$ = makeDataStringNode(Ident, $1); }
    ;
DeclFoncts:
       DeclFoncts DeclFonct                     { $$ = $1;
                                                  addSibling($$, $2);
                                                }
    |  DeclFonct                                { $$ = $1; }
    ;
DeclFonct:
       EnTeteFonct Corps                        { $$ = makeNode(DeclFonct);
                                                       addChild($$, $1);
                                                       addChild($$, $2);
                                                }
    ;
EnTeteFonct:
       TYPE IDENT '(' Parametres ')'            { $$ = makeNode(EnTeteFonct);
                                                       Node* typeNode =  makeDataStringNode(Type, $1);
                                                       addChild($$, typeNode);
                                                       addChild(typeNode, makeDataStringNode(Ident, $2));
                                                       addChild($$, $4);
                                                }
    |  VOID IDENT '(' Parametres ')'            { $$ = makeNode(EnTeteFonct);
                                                       Node* voidNode =  makeDataStringNode(Void, $1);
                                                       addChild($$, voidNode);
                                                       addChild(voidNode, makeDataStringNode(Ident, $2));
                                                       addChild($$, $4);
                                                }
    ;
Parametres:
       VOID                                     { $$ = makeNode(Parametres);
                                                       addChild($$, makeDataStringNode(Void, $1));
                                                }
    |  ListTypVar                               { $$ = $1; }
    ;
ListTypVar:
       ListTypVar ',' TYPE IDENT                { $$ = makeNode(Parametres);
                                                       addChild($$, $1);
                                                       Node* typeNode = makeDataStringNode(Type, $3);
                                                       addChild($$, typeNode);
                                                       addChild(typeNode, makeDataStringNode(Ident, $4));
                                                }
    |  TYPE IDENT                               { $$ = makeDataStringNode(Type, $1);
                                                       addChild($$, makeDataStringNode(Ident, $2));
                                                }
    ;
Corps: '{' DeclVarsLocale SuiteInstr '}'        { $$ = makeNode(Corps);
                                                        if($2->firstChild == NULL)
                                                            $2 = NULL;
                                                        else 
                                                            addChild($$, $2);
                                                        
                                                        if($3->firstChild == NULL)
                                                            $3 = NULL;
                                                        else 
                                                            addChild($$, $3);

                                                }
    ;
SuiteInstr:
       SuiteInstr Instr                         { $$ = $1;
                                                       addChild($$, $2);
                                                }
    |                                           { $$ = makeNode(SuiteInstr);
                                                }
    ;
Instr:
       LValue '=' Exp ';'                       { $$ = makeNode(Assign); addChild($$, $1); addChild($$, $3); }
    |  IF '(' Exp ')' Instr                     { $$ = makeNode(If); addChild($$, $3);
                                                       addChild($$, $5); }
    |  IF '(' Exp ')' Instr ELSE Instr          { $$ = makeNode(If); addChild($$, $3); addChild($$, $5);
                                                       Node* elseNode = makeNode(Else);
                                                       addChild($$, elseNode);
                                                       addChild(elseNode, $7); }
    
    |  WHILE '(' Exp ')' Instr                  { $$ = makeNode(While); addChild($$, $3); addChild($$, $5); }
    |  IDENT '(' Arguments  ')' ';'             { $$ = makeDataStringNode(Ident, $1); addChild($$, $3); }
    |  RETURN Exp ';'                           { $$ = makeNode(Return); addChild($$, $2); }
    |  RETURN ';'                               { $$ = makeNode(Return); }
    |  '{' SuiteInstr '}'                       { $$ = $2; }
    |  ';'                                      { $$ = NULL; }
    ;
Exp :  Exp OR TB    { $$ = makeDataStringNode(Or, $2);
                           addChild($$, $1);
                           addChild($$, $3);
                    }
    |  TB           { $$ = $1; }
    ;
TB  :  TB AND FB    { $$ = makeDataStringNode(And, $2);
                           addChild($$, $1);
                           addChild($$, $3);
                    }
    |  FB          { $$ = $1; }
    ;
FB  :  FB EQ M      { $$ = makeDataStringNode(Eq, $2);
                           addChild($$, $1);
                           addChild($$, $3);
                    }
    |  M            { $$ = $1; }
    ;
M   :  M ORDER E    { $$ = makeDataStringNode(Order, $2);
                           addChild($$, $1);
                           addChild($$, $3);
                    }
    |  E            { $$ = $1; }
    ;
E   :  E ADDSUB T   { $$ = makeDataCharNode(Addsub, $2);
                           addChild($$, $1);
                           addChild($$, $3);
                    }
    |  T            { $$ = $1; }
    ;    
T   :  T DIVSTAR F  { $$ = makeDataCharNode(Divstar, $2);
                           addChild($$, $1);
                           addChild($$, $3);
                    }
    |  F            { $$ = $1; }
    ;
F   :  ADDSUB F     { $$ = makeDataNumNode(Negation, $1); addChild($$, $2);}
    |  '!' F        { $$ = $2; }
    |  '(' Exp ')'  { $$ = $2; }
    |  NUM          { $$ = makeDataNumNode(Num, $1);}
    |  CHARACTER    { $$ = makeDataStringNode(Character, $1);}
    |  LValue       { $$ = $1; }
    |  IDENT '(' Arguments  ')' { $$ = makeDataStringNode(Ident, $1); addChild($$, $3);}
    ;
LValue:
       IDENT                    { $$ = makeDataStringNode(Ident, $1); }
    ;
Arguments:
       ListExp                  { $$ = $1; }
    |                           { $$ = makeNode(Arguments); }
    ;
ListExp:
       ListExp ',' Exp          { $$ = makeNode(ListExp); addChild($$, $1); addChild($$, $3); }
    |  Exp                      { $$ = $1; }
    ;
%%


int main(int argc, char *argv[]){

    const char* documentation = " \
        -h, --help: Affiche une description de l’interface utilisateur et termine l’exécution\n \
        -t, --tree: Affiche l’arbre abstrait sur la sortie standard.\n \
                    Nécessite un argument donnant le nom du fichier à analyser.\n \
        \n \
        Compilation :\n \
            make\n \
        Nettoyer les dossiers /bin et /obj :\n \
            make clean\n \
        \n \
        Pour compiler et lancer le programme avec les fichiers testes :\n \
            sh launch.sh\n \
        \n \
        Cela écrit les résultats dans le fichier :\n \
            rapport.txt\n \
        \n \
        Pour lancer un test manuellement on utilise la commande suivante :\n \
            ./tpcas [OPTIONS] < FILE.tpc\n";

    int affiche_arbre = 0;
    int c;

    while(1) {
        /*
        Déclare les mots-clés de nos options.
        Indique si ils ont besoins d'argument ou non.
        */
        static struct option long_options[] = 
        {
            {"tree", no_argument, NULL,  't' },
            {"help", no_argument,       NULL,  'h' },
            {NULL,   0,                 NULL,  0 }
        };

        c = getopt_long(argc, argv, "th", long_options, NULL);
        if(c == -1)
            break;

        switch(c) {
            case 't':
                /* Affiche arbre abstrait */
                printf("Affiche l'arbre abstrait :\n");
                affiche_arbre = 1;
                break;

            case 'h':
                /* Affiche interface utilisateur */
                printf("%s\n", documentation);
                break;
            default:
                printf("Erreur : Problème dans vos options ou argument d'option\n");
                return 2;
        }
    }
      // Il y a des arguments qui ne sont pas des options valides
    if(optind < argc) {
        printf("Erreur : Les variables suivantes ne correspondent pas aux paramètres -t, --tree, -h, --help : ");
        while(optind < argc)
            printf("%s ", argv[optind++]);
        printf("\n");

        return 2;
    }
    
	if(yyparse())
        return 1;

    if(affiche_arbre)
        printTree(arbre);
    
    return 0;
}

int yyerror(char* txt) {
    fprintf(stderr, "Error l.%d col.%d : %s\n", lineno, colno, txt);
    return 1;
}
