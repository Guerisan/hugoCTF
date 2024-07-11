---
title: Root-me - Docker layers
meta_title: ""
description: Exploration des secrets d'une image docker
date: 2024-07-11T05:00:00Z
image: /images/rootme_logo.png
categories:
  - Rootme
  - Facile
  - Forensic
author: Professeur_Jack
tags:
  - forensic
  - docker
draft: false
isSecret: false
---

[Ce challenge Root-Me](https://www.root-me.org/fr/Challenges/Forensic/Docker-layers?lang=fr) est une bonne introduction à la notion de *layers* dans les images docker, et de ce qu'ils peuvent nous révéler si on les explore.

## Introduction

**Le pitch :** nous devons retrouver un mod de passe servant à chiffrer un fichier de secrets.

### Image docker : le concept

Une image docker une collection ordonnée de layers, et des métadonnées associées.
Ces layers sont stockés directement dans l'image. Quand on en télécharge ou pousse une, l'on transfère en fait tous ses layers.
Une fois créés, les layers d'une image sont en lecture seule et ne peuvent pas être modifiés. Chaque layer a un identifiant unique (le hash que l'on verra plus tard), ce qui permet leur réutilisation entre différentes images.
Lorsqu'un conteneur est lancé à partir d'une image, `Docker` ajoute un layer supplémentaire inscriptible au-dessus des layers de l'image.
Cette structure en layers permet d'optimiser le stockage et la distribution des images, car les layers communs ne sont stockés qu'une seule fois sur le système.

**C'est plutôt bien pensé !**

### Le challenge

On nous fournit une archive, qui contient une image docker.
Première étape donc, l'ouvrir pour voir ce à quoi on a accès à l'intérieur :

```sh
➤ tar -xvf ch29.tar
➤ cd ch29/
➤ ls -la
total 117M
drwxr-xr-x 2 jack users 4,0K 11 juil. 14:06 1bbd61a572ad5f5e2ac0f073465d10dc1c94a71359b0adfd2c105be4c1cb2
507
-r--r--r-- 1 jack users 2,0K  1 janv.  1970 316bbb8c58be42c73eefeb8fc0fdc6abb99bf3d5686dd5145fc7bb2f32790
229.tar
-r--r--r-- 1 jack users 2,0K  1 janv.  1970 3309d6da2bd696689a815f55f18db3f173bc9b9a180e5616faf4927436cf1
99d.tar
-r--r--r-- 1 jack users  72M  1 janv.  1970 4942a1abcbfa1c325b1d7ed93d3cf6020f555be706672308a4a4a6b6d631d
2e7.tar
drwxr-xr-x 2 jack users 4,0K 11 juil. 14:06 5bcc45940862d5b93517a60629b05c844df751c9187a293d982047f01615c
b30
-r--r--r-- 1 jack users  16M  1 janv.  1970 743c70a5f809c27d5c396f7ece611bc2d7c85186f9fdeb68f70986ec6e4d1
65f.tar
drwxr-xr-x 2 jack users 4,0K 11 juil. 14:13 82ba49da0bd5d767f35d4ae9507d6c4552f74e10f29777a2a27c977789624
76d
-r--r--r-- 1 jack users 1,5K  1 janv.  1970 8d364403e7bf70d7f57e807803892edf7304760352a397983ecccb3e76ca3
9fa.tar
drwxr-xr-x 2 jack users 4,0K 11 juil. 14:06 8f0d75885373613641edc42db2a0007684a0e5de14c6f854e365c61f292f3
b4d
-r--r--r-- 1 jack users 2,4K  1 janv.  1970 b324f85f8104bfebd1ed873e90437c0235d7a43f025a047d5695fe461da71
7c6.json
-r--r--r-- 1 jack users  29M  1 janv.  1970 b58c5e8ccaba8886661ddd3b315989f5cf7839ea06bbe36547c6f49993b0d
0aa.tar
drwxr-xr-x 2 jack users 4,0K 11 juil. 16:52 ca7f60c6e2a66972abcc3147da47397d1c2edb80bddf0db8ef94770ed28c5
e16
drwxr-xr-x 2 jack users 4,0K 11 juil. 14:06 db04fe239ab708e4ab56ea0e5c1047449b7ea9e04df9db5b1b95d00c6980f
f3f
-r--r--r-- 1 jack users  573  1 janv.  1970 manifest.json
-r--r--r-- 1 jack users  111  1 janv.  1970 repositories
```

## Investigation

On sait qu'on cherche un fichier de mot de passe.

{< notice "tip" >}} Pour dégrossir, j'utilise mon outil de recherche de prédilection [ripgrep](https://github.com/BurntSushi/ripgrep), pour trouver toutes les mentions de la chaine "*pass*" {{< /notice >}}

Et effectivement, au sein du fichier `b324f85f8104bfebd1ed873e90437c0235d7a43f025a047d5695fe461da717c6.json`, qui contient toutes les informations détaillées de l'image et comment elle a été construite. 
On trouve notamment cette instruction :
```json
{"created":"2021-10-20T20:37:10.282265118Z",
 "created_by":"/bin/sh -c echo -n $(curl -s https://pastebin.com/raw/P9Nkw866) | openssl enc -aes-256-cbc -iter 10 -pass pass:$(cat /pass.txt) -out flag.enc"}
```

Une commande `openssl` ayant servi à encoder un fichier *flag* à l'aide d'un *pass.txt* !

Pour trouver ce fichier, je me suis rendu dans les layers et ai extrait les *layer.tar* jusqu'à trouver les fichiers *flag.enc* et *pass.txt* (ces fichiers layers ne sont que des liens symboliques).
```
├── ca7f60c6e2a66972abcc3147da47397d1c2edb80bddf0db8ef94770ed28c5e16
│   ├── flag.enc
│   ├── json
│   ├── layer.tar -> ../3309d6da2bd696689a815f55f18db3f173bc9b9a180e5616faf4927436cf199d.tar
│   └── VERSION
├── db04fe239ab708e4ab56ea0e5c1047449b7ea9e04df9db5b1b95d00c6980ff3f
│   ├── json
│   ├── layer.tar -> ../743c70a5f809c27d5c396f7ece611bc2d7c85186f9fdeb68f70986ec6e4d165f.tar
│   └── VERSION

```

## Résolution

Maintenant, il ne nous reste plus qu'à décoder le fichier *flag.enc* avec le pass dans les même conditions où ce premier a été chiffré :
```sh
➤ cat 82ba49da0bd5d767f35d4ae9507d6c4552f74e10f29777a2a27c97778962476d/pass.txt 
d4428185a6202a1c5806d7cf4a0bb738a05c03573316fe18ba4eb5a21a1bc8ea⏎   

➤ openssl enc -aes-256-cbc -iter 10 -d -in flag.enc -out flag.txt
enter AES-256-CBC decryption password:
```

Et c'est flag !