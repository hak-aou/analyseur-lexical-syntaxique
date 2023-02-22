/* tree.h */

typedef enum {
  Prog,
  DeclVarsGlobale,
  DeclVarsLocale, 
  InitVarsLocale,
  Declarateurs,
  DeclFoncts,
  DeclFonct,
  EnTeteFonct,
  Parametres,
  ListTypVar,
  Corps,
  SuiteInstr,
  Instr,
  Exp,
  TB,
  FB, 
  M,
  E,
  T,
  F,
  LValue,
  Arguments,
  ListExp,
  Type,
  Ident,
  Void,
  If,
  Else,
  While,
  Return,
  Or,
  And,
  Eq,
  Order,
  Addsub,
  Divstar,
  Num,
  Character,
  Assign,
  Negation

  /* list all other node labels, if any */
  /* The list must coincide with the string array in tree.c */
  /* To avoid listing them twice, see https://stackoverflow.com/a/10966395 */
} label_t;

typedef union {
  char string[64];
  char character;
  int num;
} Data;

typedef struct Node {
  label_t label;
  struct Node *firstChild, *nextSibling;
  int lineno;

  Data data;
} Node;

Node *makeNode(label_t label);
void addSibling(Node *node, Node *sibling);
void addChild(Node *parent, Node *child);
void deleteTree(Node*node);
void printTree(Node *node);

Node *makeDataStringNode(label_t label, char* data);
Node *makeDataCharNode(label_t label, char data);
Node *makeDataNumNode(label_t label, int num);

#define FIRSTCHILD(node) node->firstChild
#define SECONDCHILD(node) node->firstChild->nextSibling
#define THIRDCHILD(node) node->firstChild->nextSibling->nextSibling
