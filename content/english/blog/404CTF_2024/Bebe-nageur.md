---
title: 404CTF - Bébé nageur
meta_title: ""
description: 404CTF 2024 - Crypto - Bébé nageur
date: 2024-07-14T18:00:00Z
image: /images/404CTF_logo.png
categories:
  - 404CTF
  - Crypto
  - Intro
author: Demat
tags:
  - crypto
  - affine-cipher
draft: false
---

## Description

### Énoncé

> Vous ressortez de votre premier cours de natation et quelqu'un vous a laissé un petit mot dans votre casier. Vous suspectez votre rival que vous venez juste de battre à plate couture lors d'une course effrénée dans le bassin des bébés nageurs. Déchiffrez ce message.

**Voir le code source :** [`challenge.py`](/hugoCTF/bebe-nageur/challenge.py)

```python
from flag import FLAG
import random as rd

charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789{}_-!"

def f(a,b,n,x):
    return (a*x+b)%n

def encrypt(message,a,b,n):
    encrypted = ""
    for char in message:
        x = charset.index(char)
        x = f(a,b,n,x)
        encrypted += charset[x]

    return encrypted

n = len(charset)
a = rd.randint(2,n-1)
b = rd.randint(1,n-1)

print(encrypt(FLAG,a,b,n))

# ENCRYPTED FLAG : -4-c57T5fUq9UdO0lOqiMqS4Hy0lqM4ekq-0vqwiNoqzUq5O9tyYoUq2_
```

## Exploitation

### Analyse du chiffrement

Le challenge est un script Python qui chiffre un message caractère par caractère avec la fonction `f`.
Il s'agit d'un chiffrement affine, une méthode de chiffrement par substitution mono-alphabétique qui utilise une fonction de la forme `f(x) = (ax + b) mod n`.

Ici, `a` et `b` sont des entiers choisis au hasard, et `n` est la taille de l'alphabet.

Le flag chiffré est également fourni : `-4-c57T5fUq9UdO0lOqiMqS4Hy0lqM4ekq-0vqwiNoqzUq5O9tyYoUq2_`.

### Attaque par force brute

Vu la petite taille de l'alphabet, on peut facilement casser le chiffrement par force brute. En effet, `n = 67`, il y a donc seulement `n * (n-1) = 4422` combinaisons possibles pour `a` et `b`.

Pour cela, on tente de déchiffrer le flag avec toutes les combinaisons possibles de `a` et `b`, et on vérifie si le résultat correspond à un flag valide (avec le préfixe `404CTF{`).

L'inverse de la fonction `f` est `f⁻¹(x) = (a⁻¹ * (x - b)) mod n`, où `a⁻¹` est l'inverse de `a` modulo `n`, c'est-à-dire `a * a⁻¹ ≡ 1 (mod n)`.

En Python, l'inverse de `a` modulo `n` se calcule simplement avec `pow(a, -1, n)`.

```python
ENCRYPTED = "-4-c57T5fUq9UdO0lOqiMqS4Hy0lqM4ekq-0vqwiNoqzUq5O9tyYoUq2_"

charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789{}_-!"


def inv(a: int, b: int, n: int, x: int) -> int:
    return (x - b) * pow(a, -1, n) % n


def decrypt(encrypted: str, a: int, b: int, n: int) -> str:
    decrypted = ""
    for char in encrypted:
        x = charset.index(char)
        x = inv(a, b, n, x)
        decrypted += charset[x]
    return decrypted


def main() -> None:
    n = len(charset)
    for a in range(2, n):
        for b in range(1, n):
            dec = decrypt(ENCRYPTED, a, b, n)
            if dec.startswith("404CTF{"):
                print(f"{a=}, {b=}")
                print(dec)


if __name__ == "__main__":
    main()
```

Grâce à ce script, on trouve rapidement les valeurs de `a` et `b` qui permettent de déchiffrer le flag :

```text
a=19, b=6
404CTF{Th3_r3vEnGE_1S_c0minG_S0oN_4nD_w1Ll_b3_TErRiBl3_!}
```
