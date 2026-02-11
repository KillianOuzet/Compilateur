# Facile - Analyseur Lexical

Projet de compilation utilisant Flex et CMake.

## Prérequis

- **CMake**
- **Flex** (via Homebrew sur macOS) :
  ```bash
  brew install flex
  ```

## Compilation

Pour compiler le projet sur macOS (où la librairie `fl` n'est pas standard), utilisez les commandes suivantes :

```bash
mkdir -p build
cd build

# Configuration avec le chemin vers Flex (Homebrew)
cmake -DBISON_EXECUTABLE="$(brew --prefix bison)/bin/bison" -DCMAKE_EXE_LINKER_FLAGS="-L$(brew --prefix flex)/lib" -DCMAKE_C_FLAGS="-I$(brew --prefix flex)/include" -DCMAKE_BUILD_TYPE=Debug ..

# Compilation
make
```
