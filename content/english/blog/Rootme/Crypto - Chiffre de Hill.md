---
title: Crypto - Chiffre de Hill
meta_title: ""
description: Crypto - Chiffre de Hill
date: 2024-07-17T18:00:00Z
image: /images/rootme_logo.png
categories:
  - Rootme
  - Crypto
  - Moyen
author: Demat
tags:
  - crypto
  - hill-cipher
  - known-plaintext
  - matrix
draft: false
isSecret: true
---

## Description

### Énoncé

**Lien du challenge : [Crypto - Chiffre de Hill](https://www.root-me.org/fr/Challenges/Cryptanalyse/Chiffre-de-Hill)**

> #### Benny n'a qu'à bien se tenir !
>
> Benny a reçu ce message comportant des informations cruciales concernant Lester, son ami :
>
> ```text
> EgiMbrC7AbHOTyCiRJTU4eWlQwfgK4?fGQvzcjXBBw?NpxK6rv3OsObp?N9vjIqzHC?O9WwOT1VVtu32my2CzNNkHTozl5W,nE7Lm4rBJucP8XezREIuzgl0C7ANnn.561s9jBIYgECq!8XezREBDQ6sOG2i44iQIligvf9.Auk5hgNMuzREcjXzvPWrieWlQwfgK4km0xS?o0tuPB7VJo0t,nOwCUZAyxYyf0LvcfrIFmbPJDoAs9xaJA!cQF8?ffkln7SKO.h CVdc?JqPiAK9c8jt5Ck9ZAyrVP.y13pyC6OdvrN1dkHTseEgnDHQGEfKjBIf90KjAyFNBBwtXMaTZpbycC3HiqFp07SK44inxH5YAvEEml?CKjNQoCJwzNNbHOTyCnE7Lm4uZFCir
> ```
>
> Un de nos espions a pu trouver quelques informations :
>
> - La clé de chiffrement est de taille 3x3 ;
> - Alphabet utilisé :
>
> ```text
> {'!': 8, ' ': 42, ',': 58, '.': 6, '1': 7, '0': 1, '3': 34, '2': 37, '5': 3, '4': 47, '7': 43, '6': 63, '9': 54, '8': 13, '?': 60, 'A': 35, 'C': 57, 'B': 16, 'E': 31, 'D': 64, 'G': 9, 'F': 23, 'I': 29, 'H': 32, 'K': 55, 'J': 53, 'M': 21, 'L': 5, 'O': 52, 'N': 41, 'Q': 40, 'P': 26, 'S': 22, 'R': 18, 'U': 51, 'T': 15, 'W': 17, 'V': 62, 'Y': 45, 'X': 66, 'Z': 50, 'a': 25, 'c': 38, 'b': 0, 'e': 30, 'd': 33, 'g': 14, 'f': 2, 'i': 10, 'h': 4, 'k': 59, 'j': 39, 'm': 11, 'l': 28, 'o': 12, 'n': 19, 'q': 24, 'p': 49, 's': 46, 'r': 61, 'u': 20, 't': 27, 'w': 36, 'v': 44, 'y': 56, 'x': 48, 'z': 65}
> ```
>
> - Le message, rédigé en anglais, semble parler de la méthode utilisée.
>
> Aidez Benny à déchiffrer ce message.
>
> #### Ressources associées
>
> - [🇬🇧 Hill_cipher](https://en.wikipedia.org/wiki/Hill_cipher) (en.wikipedia.org)
> - [🇬🇧 092mat483_known_plaintext_attack_of_hill_cipher.pdf](https://www.root-me.org/IMG/pdf/092mat483_known_plaintext_attack_of_hill_cipher.pdf) (www.root-me.org)

## Exploitation

### Chiffre de Hill

L'énoncé mentionne que le message parle de la méthode utilisée, et la 2ème ressource renvoie vers une attaque de clair connu (known plaintext).
Vu que l'alphabet est connu, nous allons probablement devoir trouver une variation du texte `hill cipher` dans le message.

La [première ressource](https://en.wikipedia.org/wiki/Hill_cipher) est la page Wikipédia expliquant le fonctionnement du chiffrement de Hill. Il s'agit de la simple multiplication d'une matrice carrée n×n inversible (la clé) avec un vecteur (le message, découpé en blocs de n caractères).
Pour décoder le message, il suffit de multiplier le message chiffré par la matrice inverse de la clé.

La difficulté réside dans le fait qu'il s'agit d'arithmétique modulaire, de modulo la taille de l'alphabet. Calculer l'inverse modulaire d'une matrice n'est pas trivial.

### Attaque par clair connu

La [seconde ressource](https://www.root-me.org/IMG/pdf/092mat483_known_plaintext_attack_of_hill_cipher.pdf) explique comment retrouver la clé à partir d'un texte connu et de son équivalent dans le texte chiffré, en résolvant un système d'équations.

Dans le document, ils utilisent 2 groupes de 2 lettres pour déduire une clé de taille 2×2. Nous allons donc devoir trouver 3 blocs de 3 lettres successives pour notre clé de 3×3.
Heureusement, le clair connu contient 11 lettres.

L'attaque se base sur le fait qu'un même n-gramme sera toujours chiffré de la même façon pour une clé de n×n.
Nous allons donc essayer de déduire une clé pour les différents trigrammes du message chiffré, en utilisant le clair connu.

Comme le message est chiffré par blocs de 3 lettres, on va devoir tester 3 différents alignements des sous-chaînes de 9 lettres du clair connu :

```text
hill ciph
ill ciphe
ll cipher
```

Ça tombe bien, il y a exactement assez de lettres pour tout tester  !

### Exemple de chiffrement

Pour calculer la clé à partir de 9 lettres du message chiffré et 9 lettres du message en clair, nous utilisons `numpy` pour optimiser les manipulations de données et `sympy` pour calculer facilement l'inverse modulaire d'une matrice.

Par exemple, pour le texte chiffré `abcdefghi` et le texte clair `hill ciph`, on obtient les vecteurs suivants, encodés avec l'alphabet donné :

- `"abcdefghi"` → `v1 = [25, 0, 38, 33, 30, 2, 14, 4, 10]`
- `"hill ciph"` → `v2 = [4, 10, 28, 28, 42, 38, 10, 49, 4]`

On cherche d'abord à représenter le système d'équations sous la forme d'une matrice :

```text
[ 4 10 28  0  0  0  0  0  0]
[ 0  0  0  4 10 28  0  0  0]
[ 0  0  0  0  0  0  4 10 28]
[28 42 38  0  0  0  0  0  0]
[ 0  0  0 28 42 38  0  0  0]
[ 0  0  0  0  0  0 28 42 38]
[10 49  4  0  0  0  0  0  0]
[ 0  0  0 10 49  4  0  0  0]
[ 0  0  0  0  0  0 10 49  4]
```

Puis on inverse cette matrice modulo 67, qui est la taille de notre alphabet, et on obtient :

```text
[ 1  0  0 11  0  0 56  0  0]
[ 0  0  0 28  0  0  2  0  0]
[31  0  0 65  0  0 20  0  0]
[ 0  1  0  0 11  0  0 56  0]
[ 0  0  0  0 28  0  0  2  0]
[ 0 31  0  0 65  0  0 20  0]
[ 0  0  1  0  0 11  0  0 56]
[ 0  0  0  0  0 28  0  0  2]
[ 0  0 31  0  0 65  0  0 20]
```

Pour obtenir la clé qui donne `"hill ciph"` à partir de `"abcdefghi"`, il suffit de multiplier la matrice inversée par v1 pour obtenir les valeurs des 9 cases de la matrice de clé, ce qui donne ici : `[33, 14, 51, 18, 44, 20, 17, 9, 34]`.

Retranscrite sous forme de matrice, on a cette clé :

```text
[33 18 17]
[14 44  9]
[51 20 34]
```

On peut vérifier qu'avec l'alphabet donné, déchiffrer `"abcdefghi"` avec cette clé donne bien `"hill ciph"`.

### Implémentation de l'attaque

L'algorithme pour trouver la bonne clé pour notre message chiffré consiste à itérer sur chaque groupe de 9 caractères dans le message chiffré (en commençant tous les 3 caractères), à calculer la clé en conjonction avec chacune des 3 sous-chaînes du clair connu, et à déchiffrer le message complet avec cette clé.

Si le clair connu s'y trouve complètement, on l'affiche, car c'est une clé potentielle.

Voici le code Python que j'ai utilisé pour résoudre le challenge :

```python
#!/usr/bin/env python3

from functools import cache
from typing import Iterator, TypeAlias

import numpy as np
import numpy.typing as npt
from sympy import Matrix
from sympy.matrices.common import NonInvertibleMatrixError

NDIntArray: TypeAlias = npt.NDArray[np.int_]

# fmt: off
ALPHABET = {
    "!": 8, " ": 42, ",": 58, ".": 6, "1": 7, "0": 1, "3": 34, "2": 37, "5": 3, "4": 47,
    "7": 43, "6": 63, "9": 54, "8": 13, "?": 60, "A": 35, "C": 57, "B": 16, "E": 31, "D": 64,
    "G": 9, "F": 23, "I": 29, "H": 32, "K": 55, "J": 53, "M": 21, "L": 5, "O": 52, "N": 41,
    "Q": 40, "P": 26, "S": 22, "R": 18, "U": 51, "T": 15, "W": 17, "V": 62, "Y": 45, "X": 66,
    "Z": 50, "a": 25, "c": 38, "b": 0, "e": 30, "d": 33, "g": 14, "f": 2, "i": 10, "h": 4,
    "k": 59, "j": 39, "m": 11, "l": 28, "o": 12, "n": 19, "q": 24, "p": 49, "s": 46, "r": 61,
    "u": 20, "t": 27, "w": 36, "v": 44, "y": 56, "x": 48, "z": 65,
}
# fmt: on

ALPHABET_REV = {v: k for k, v in ALPHABET.items()}  # Reverse lookup table for the alphabet

ALPHABET_LENGTH = len(ALPHABET)  # 67


CIPHERTEXT = (
    "EgiMbrC7AbHOTyCiRJTU4eWlQwfgK4?fGQvzcjXBBw?NpxK6rv3OsObp?N9vjIqzHC?O9WwOT1VVtu32m"
    "y2CzNNkHTozl5W,nE7Lm4rBJucP8XezREIuzgl0C7ANnn.561s9jBIYgECq!8XezREBDQ6sOG2i44iQIl"
    "igvf9.Auk5hgNMuzREcjXzvPWrieWlQwfgK4km0xS?o0tuPB7VJo0t,nOwCUZAyxYyf0LvcfrIFmbPJDo"
    "As9xaJA!cQF8?ffkln7SKO.h CVdc?JqPiAK9c8jt5Ck9ZAyrVP.y13pyC6OdvrN1dkHTseEgnDHQGEfK"
    "jBIf90KjAyFNBBwtXMaTZpbycC3HiqFp07SK44inxH5YAvEEml?CKjNQoCJwzNNbHOTyCnE7Lm4uZFCir"
)

KNOWN = "hill cipher"  # Known plaintext, exactly 11 characters long


def mat_inv_mod(mat_np: NDIntArray, mod: int) -> NDIntArray | None:
    """Get the modular inverse of the given matrix if it exists, otherwise return None"""
    mat_sym = Matrix(mat_np)
    try:
        mat_sym_inv = mat_sym.inv_mod(mod)
        return np.asarray(mat_sym_inv, int)
    except NonInvertibleMatrixError:
        return None


def encode(msg: str) -> NDIntArray:
    """Encode the given string into a matrix using the alphabet"""
    return np.asarray([ALPHABET[i] for i in msg], int).reshape(-1, 3)


def decode(msg: NDIntArray) -> str:
    """Decode the given matrix into a string using the alphabet"""
    return "".join([ALPHABET_REV[i % ALPHABET_LENGTH] for i in msg.reshape(-1)])


def encrypt(msg: str, key: NDIntArray) -> str:
    """Encrypt the given message using the given key"""
    msg_num = encode(msg)
    crypted_num = np.dot(msg_num, key)
    crypted = decode(crypted_num)
    return crypted


def decrypt(crypted: str, key: NDIntArray) -> str | None:
    """Decrypt the given crypted message using the given key"""
    key_inv = mat_inv_mod(key, ALPHABET_LENGTH)
    if key_inv is None:
        return None
    crypted_num = encode(crypted)
    plain_num = np.dot(crypted_num, key_inv)
    plain = decode(plain_num)
    return plain


def ngram_iter(text: str, n: int, step: int = 1) -> Iterator[str]:
    """Iterate over the successive ngrams of the given text

    Example: ngram_iter("abcde", 3) -> "abc", "bcd", "cde" """
    return (text[i : i + n] for i in range(0, len(text) - n + 1, step))


@cache
def get_inverse_matrix(plain: str) -> NDIntArray | None:
    """Get the 3x3 modular inverse matrix of the given 9-character plaintext

    The result is memoized to avoid recomputing it for the same plaintext"""
    plain_num = encode(plain)
    mat: Matrix = Matrix.zeros(9)

    # Fill a 9x9 matrix with the encoded plaintext
    # For the plaintext [p1 p2 p3 p4 p5 p6 p7 p8 p9], the matrix is:
    # [p1 p2 p3  0  0  0  0  0  0]
    # [ 0  0  0 p1 p2 p3  0  0  0]
    # [ 0  0  0  0  0  0 p1 p2 p3]
    # [p4 p5 p6  0  0  0  0  0  0]
    # [ 0  0  0 p4 p5 p6  0  0  0]
    # [ 0  0  0  0  0  0 p4 p5 p6]
    # [p7 p8 p9  0  0  0  0  0  0]
    # [ 0  0  0 p7 p8 p9  0  0  0]
    # [ 0  0  0  0  0  0 p7 p8 p9]
    nums: NDIntArray
    for i, nums in enumerate(plain_num):
        for j in range(3):
            mat[i * 3 + j, 3 * j] = [nums.tolist()]

    try:
        inv_mat = mat.inv_mod(ALPHABET_LENGTH)
        return np.asarray(inv_mat, int)
    except NonInvertibleMatrixError:
        return None


def solve_key(plain: str, crypted: str) -> NDIntArray:
    """Get a key from the given 9-character plaintext and ciphertext, using the modular inverse
    matrix of the plaintext to solve the system of equations: `key * plaintext = ciphertext`"""
    inv_mat = get_inverse_matrix(plain)
    if inv_mat is None:
        raise ValueError("The given plaintext is not invertible")

    crypted_num = encode(crypted).reshape(-1)  # Get the ciphertext vector
    res: NDIntArray = np.dot(inv_mat, crypted_num) % ALPHABET_LENGTH
    return res.reshape(-1, 3).transpose()


def main() -> None:
    print("Cipher:", CIPHERTEXT)
    print()

    # Iterate over all 9-character substrings of the ciphertext in steps of 3, and try to find
    # a key that decrypts it to the known plaintext
    for sub_cipher in ngram_iter(CIPHERTEXT, 9, 3):
        for sub_known in ngram_iter(KNOWN, 9):
            key = solve_key(sub_known, sub_cipher)
            plain = decrypt(CIPHERTEXT, key)
            if plain is not None and KNOWN in plain:
                # If the decrypted text contains the known plaintext, we found a possible key
                print("> Plaintext:", plain)
                print("> Key:")
                print(key)
                print()


if __name__ == "__main__":
    main()
```

Au final le clair connu était bien `hill cipher` tout en minuscules (dans mes premier essais je l'avais cherché avec une majuscule à Hill).

On obtient trois résultats possibles pour la clé :

```text
[48  9  2]   [16 57 61]   [62 45 27]
[ 9 46 16]   [19  2 38]   [18 11 30]
[58 14 62]   [51  3 17]   [21  5 45]
```

Seule la première décode correctement le message, qui est le suivant :

> About the creator of hill cipher, he was an american mathematician and educator who was interested in applications of mathematics to communications. Among his notable contributions was the hill cipher. By the way, the flag for this challenge is *[censuré]*. He also developed methods for detecting errors in telegraphed code numbers and wrote two books. His method, hill cipher, was created in 1929.
