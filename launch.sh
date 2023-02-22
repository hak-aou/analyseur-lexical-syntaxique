make
RESULTAT="resultat_test.txt"

echo "(0 = Pas erreur syntaxique)" > $RESULTAT
echo "(1 = Contient une erreur syntaxique)\n" >> $RESULTAT

echo "\nFichiers teste censé être bon : " >> $RESULTAT
# Teste sur des fichiers considéraient comme bon
for file in test/good/* ; do
    ./bin/tpcas < $file >> $RESULTAT 2>&1
    echo $file "- Résultat :" $? >> $RESULTAT
done

echo "\nFichiers teste censé contenir une erreur : " >> $RESULTAT

# Teste sur des fichiers considéraient comme erronés
for file in test/syn-err/* ; do
    ./bin/tpcas < $file >> $RESULTAT 2>&1
    echo $file "- Résultat :" $? >> $RESULTAT
done

make clean