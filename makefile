# Makefile Projet Flex
# 30/12/2022
# Hakim AOUDIA, Richard ARNAOUT
# Version finale

CC=gcc
CFLAGS=-Wall
LDFLAGS=-Wall -lfl
EXEC_FLEX=tpcas
EXEC_BISON=tpcas

# Fichiers sources (.lex, .y, tree.c, tree.h)
SRC=./src/
# Fichiers intermédiaires (lex.yy.c, lex.yy.o, .tab.c, .tab.h, .tab.o, tree.o)
OBJ=./obj/
# Fichier executable (tpcas)
BIN=./bin/

 $(BIN)$(EXEC_FLEX): $(OBJ)$(EXEC_BISON).tab.o  $(OBJ)lex.yy.o  $(OBJ)tree.o
	$(CC) -o $@ $^ $(LDFLAGS)

. $(OBJ)$(EXEC_BISON).tab.c : $(SRC)$(EXEC_BISON).y
	bison -d $< -o ./obj/$(EXEC_BISON).tab.c -v

 $(OBJ)lex.yy.c:  $(SRC)$(EXEC_FLEX).lex  $(OBJ)$(EXEC_BISON).tab.h 
	flex -o  $(OBJ)lex.yy.c  $(SRC)$(EXEC_FLEX).lex 

 $(OBJ)tree.o:  $(SRC)tree.c  $(SRC)tree.h
	$(CC) -o $@ -c $< $(CFLAGS)

 $(OBJ)%.o:  $(OBJ)%.c
	$(CC) -o $@ -c $< $(CFLAGS)

clean:
	rm -f  $(OBJ)lex.yy.*  $(OBJ)$(EXEC_BISON).tab.*  $(OBJ)$(EXEC_BISON)  $(OBJ)*.o
	rm -f  $(BIN)$(EXEC_BISON)
	rm $(OBJ)$(EXEC_BISON).output