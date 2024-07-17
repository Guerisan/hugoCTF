---
title: Cracking - ELF x64 - Basic KeygenMe
meta_title: ""
description: Cracking - ELF x64 - Basic KeygenMe
date: 2024-07-16T18:00:00Z
image: /images/rootme_logo.png
categories:
  - Rootme
  - Cracking
  - Reverse
  - Facile
author: Demat
tags:
  - reverse-engineering
  - decompilation
  - keygen
draft: false
isSecret: true
---

## Description

### Énoncé

**Lien du challenge : [Cracking - ELF x64 - Basic KeygenMe](https://www.root-me.org/fr/Challenges/Cracking/ELF-x64-Basic-KeygenMe)**

> #### Easy to reverse
>
> Trouvez le serial pour l’utilisateur "root-me.org".
>
> Le flag est le sha256 du serial valide.
>
> #### Fichiers associés
>
> - [`ch36.bin`](/hugoCTF/basic-keygenme/ch36.bin)
>
> #### Ressources associées
>
> - [🇫🇷 Reverse Engineering pour Débutants - Dennis Yurichev (Reverse Engineering)](https://repository.root-me.org/Reverse%20Engineering/FR%20-%20Reverse%20Engineering%20pour%20D%C3%A9butants%20-%20Dennis%20Yurichev.pdf)
> - [🇬🇧 Reverse Engineering for Beginners - Dennis Yurichev (Reverse Engineering)](https://repository.root-me.org/Reverse%20Engineering/EN%20-%20Reverse%20Engineering%20for%20Beginners%20-%20Dennis%20Yurichev.pdf)

## Exploitation

### Analyse du binaire

Le challenge consiste à trouver un serial pour l'utilisateur `root-me.org` dans le binaire [`ch36.bin`](/hugoCTF/basic-keygenme/ch36.bin).

*Note : le challenge s'appelle `Basic KeygenMe`, mais il n'est pas nécessaire de créer un keygen pour le résoudre, il suffit de trouver un serial valide.*

Il s'agit d'un exécutable ELF x86-64, que l'on peut analyser avec `Ghidra` ou `IDA` par exemple.
Ici, nous allons utiliser `IDA Free` pour décompiler le code et comprendre la fonction de vérification du serial afin de créer un keygen.

### Analyse du binaire avec IDA

Après avoir ouvert le binaire dans `IDA Free`, on peut voir que le binaire est extrêmement simple (il ne fait que 960 octets) et qu'il ne contient que 3 fonctions. Il a probablement été écrit directement en assembleur.

![Premier aperçu avec IDA](/images/basic-keygenme/premier-apercu.png)

#### Nettoyage du code

Nous allons tout d'abord renommer les fonctions et les variables, et corriger leurs types, pour plus de clarté.

Les deux fonctions auxiliaires sont `strlen` et `check` (qui vérifie le serial).

Fonction `start` nettoyée :

![Fonction start nettoyée](/images/basic-keygenme/function-start.png)

Fonction `strlen` :

![Fonction strlen](/images/basic-keygenme/function-strlen.png)

Fonction `check` :

![Fonction check](/images/basic-keygenme/function-check.png)

#### Fonction `start`

La fonction `start` commence par afficher un prompt demandant un login à l'utilisateur, puis elle lit le contenu du fichier `.m.key`, qui contient le serial attendu pour l'utilisateur `root-me.org`.
Elle appelle ensuite la fonction `check` avec ces deux chaînes en argument, et affiche un message en fonction du résultat : si `check` renvoie 0, le serial est valide, sinon il est invalide.

#### Fonction `check`

Le cœur du challenge se trouve dans la fonction `check`, qui vérifie si le serial fourni par l'utilisateur est correct.

Elle prend deux chaînes en argument : le login et le serial, et elle effectue une vérification caractère par caractère.

Voici une version Python de la fonction `check` :

```python
def check(login: bytes, password: bytes) -> int:
    size = len(login)
    if size == 1:
        return 0x1337
    for i in range(size):
        if login[i] - i + 20 != password[i]:
          return 0x1337
    return 0
```

Il s'agit d'une fonction très simple qui vérifie si le caractère à la position `i` du serial est égal à `login[i] - i + 20`.

### Création du keygen

#### Script Python

Maintenant que nous avons compris le fonctionnement de la fonction `check`, nous pouvons créer un keygen pour trouver un serial valide pour l'utilisateur `root-me.org`.

Voici un script Python qui génère un serial valide pour le login passé en argument, calcule le SHA256 du serial pour obtenir le flag, et crée aussi le fichier `.m.key` :

```python
#!/usr/bin/python3

from hashlib import sha256

KEY_FILE = ".m.key"


def keygen(login: bytes) -> bytes:
    return bytes(c - i + 20 for i, c in enumerate(login))


def main(argv: list[str]) -> None:
    if len(argv) != 2:
        print(f"Usage: {argv[0]} <login>")
        return

    login = argv[1]
    key = keygen(login.encode("ascii"))
    flag = sha256(key).hexdigest()
    print(f"Login: {login}")
    print(f"Key:   {key!r}")
    print(f"Flag:  {flag}")

    with open(KEY_FILE, "wb") as f:
        f.write(key)

    print(f"Key saved to '{KEY_FILE}'")


if __name__ == "__main__":
    import sys

    main(sys.argv)
```

#### Résultat

![Résultat du keygen](/images/basic-keygenme/result.png)

## Autres possibilités d'exploitation

Il aurait également été possible de résoudre ce challenge avec d'autres approches :

- Utilisation d'un debugger tel que `gdb` pour déterminer, caractère par caractère, le serial attendu lors de l'exécution du binaire
- Exécution symbolique avec `angr` ou `miasm` pour calculer le serial

Ces approches sont efficaces pour trouver un serial sans comprendre le fonctionnement du binaire, mais elles ne permettent pas de créer un keygen.
