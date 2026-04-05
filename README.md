# Compilateur "Facile"

Un compilateur complet pour le langage "facile", générant du code assembleur CIL (.NET/Mono). 
Ce projet universitaire est construit en C et s'appuie sur **Flex** (analyse lexicale), **Bison** (analyse syntaxique et création de l'AST) et la **GLib** (manipulation des structures de données).

## Prérequis

Pour compiler et exécuter ce projet, plusieurs outils sont nécessaires : CMake, un compilateur C, Flex, Bison, la GLib (et pkg-config), ainsi que Mono.

### Sur Linux (Ubuntu/Debian - Environnement de correction)
Les paquets s'installent facilement via `apt` :
```bash
sudo apt update
sudo apt install build-essential cmake flex bison libglib2.0-dev pkg-config mono-devel
```

### Sur macOS
Vous pouvez tout installer via [Homebrew](https://brew.sh/) (les *Command Line Tools* d'Apple fournissent déjà Clang) :
```bash
brew install flex bison glib pkg-config mono
```

---

## Compilation

### Sur Linux
La configuration est standard. Exécutez ces commandes à la racine du projet :
```bash
mkdir -p build
cd build
cmake -DCMAKE_BUILD_TYPE=Release ..
make
```

### Sur macOS
La configuration demande de spécifier les chemins vers les versions Homebrew de Flex/Bison et de forcer l'utilisation de `clang` pour éviter les conflits d'en-têtes avec GCC. Exécutez ces commandes à la racine du projet :
```bash
mkdir -p build
cd build
CC=clang cmake -DBISON_EXECUTABLE="$(brew --prefix bison)/bin/bison" -DCMAKE_EXE_LINKER_FLAGS="-L$(brew --prefix flex)/lib" -DCMAKE_C_FLAGS="-I$(brew --prefix flex)/include" -DCMAKE_BUILD_TYPE=Release ..
make
```

---

## Utilisation du compilateur

Une fois le projet compilé, un exécutable `facile` est généré dans le dossier `build`. La chaîne de compilation complète d'un fichier `.facile` se déroule en 3 étapes (identiques sur Linux et macOS) :

**1. Compiler le code source en Assembleur CIL**
```bash
./facile mon_programme.facile
```
> *Cette commande analyse le code source et génère un fichier `mon_programme.il` contenant le code assembleur.*

**2. Assembler le code CIL en exécutable .NET**
```bash
ilasm mon_programme.il
```
> *L'outil `ilasm` (fourni par Mono) traduit l'assembleur textuel en un exécutable binaire `mon_programme.exe`.*

**3. Exécuter le programme**
```bash
mono mon_programme.exe
```
> *Sur macOS et Linux, les fichiers `.exe` s'exécutent au travers de la machine virtuelle Mono.*