---
title: Root-me - Réseau - OSPF Authentification
meta_title: ""
description: Retrouvez la clé secrète dans cet échange OSPF chiffré.
date: 2024-15-07T05:00:00Z
image: /images/rootme_logo.png
categories:
  - Réseau
  - Facile
author: Emma.exe
tags:
  - Forensic
  - Rootme
draft: false
---

## Introduction

Ce challenge de réseau permet de se pencher sur l'authentification des protocoles réseau tels que OSPF.
Si ce protocole n'est pas correctement protégé, les routeurs seront exposés à des attaques de types "Injection de routes". Cela permet à un attaquant de rediriger le trafic vers lui.
Mais qu'en est-il de la sécurité du protocole OSPF ?

Pour la résolution de ce challenge je vous propose deux niveaux d'aide : 
- Le premier niveau sous la forme d'indices et de ressources à explorer pour résoudre le challenge, sans pour autant donner la solution
- Le deuxième niveau qui présente un exemple de résolution.

{{< notice "tip" >}} Essayez de ne pas regarder la solution si vous voulez vraiment progresser. Une fois le challenge résolu, il peut être intéressant de la regarder pour apprendre de nouvelles techniques ! {{< /notice >}}

{{< tabs >}} {{< tab "Niveau 1" >}}

OSPF est un protocole de routage qui supporte trois types d'authentification :
- Null Authentification : Pas d'authentification
- Simple Password Authentification : Les paquets contiennent un mot de passe en clair...
- Cryptographic Authentification : Les paquets contiennent un code d'authentification valide tel que Keyed-MD5 ou HMAC-SHA-256.

Vous l'aurez compris, pour ce challenge nous sommes dans le 3e cas.
Vous pouvez le vérifier en analysant le champ "Auth Type" des paquets.
Vous pouvez aussi connaître l'algorithme utilisé grâce à la valeur dans le champ "Auth Crypt Data Length".

La première étape de ce chalenge est donc d'analyser les trames afin d'en extraire les hash.
Pour cela, il existe de nombreux outils tel que Wireshark, tcpdump ou ettercap.

Vous pouvez tout aussi bien créer un algorithme personnalisé afin d'extraire les hashes.
Si vous choisissez cette option, prenez bien en compte le fait que le header OSPF contient également un champ "Auth Crypt Sequence Number" afin d'éviter les attaques par rejeu.

{{< /tab >}}

En faisant quelques recherches, on tombe sur cette ressource : https://github.com/shaheemirza/OSPFMD5Crack
Cela nous guide afin d'extraire et cracker les hashes OSPF.

1. Extraire les hash de la capture avec Ettercap : 
```sh
ettercap -Tqr ospf_md5_dump.pcapng
```

2. Récupérer les hash et préparer un fichier d'input : 
```sh
cat raw-hashes.txt | cut -d ":" -f 2 >> net-md5-hashes.txt
```

3. Cracker le mot de passe avec john : 

```sh
john net-md5-hashes.txt --wordlist=/usr/share/wordlists/rockyou.txt
```

Et voilà !

{{< /tab >}}{{< /tabs >}}
