---
title: Root-me - Réseau - Wired Equivalent Privacy
meta_title: ""
description: Trouvez le mot de passe de ce WiFi.
date: 2024-16-07T05:00:00Z
image: /images/rootme_logo.png
categories:
  - Réseau
  - Moyen
author: Emma.exe
tags:
  - Réseau
  - WEP
  - WiFi
draft: false
---

## Introduction

Dans ce challenge, il faut analyser les échanges WEP entre des clients et une AP afin de découvrir le mot de passe. 

Pour la résolution de ce challenge je vous propose deux niveaux d'aide : 
- Le premier niveau sous la forme d'indices et de ressources à explorer pour résoudre le challenge, sans pour autant donner la solution
- Le deuxième niveau qui présente un exemple de résolution.

{{< notice "tip" >}} Essayez de ne pas regarder la solution si vous voulez vraiment progresser. Une fois le challenge résolu, il peut être intéressant de la regarder pour apprendre de nouvelles techniques ! {{< /notice >}}

## Résolution

{{< tabs >}} {{< tab "Niveau 1" >}}

Dans ce challenge, nous avons à faire à un échange WEP comme l'indique le challenge.
Voici une documentation qui résume bien les différents points importants du WEP : https://rya-sge.github.io/access-denied/2022/04/28/protocole-wep/#réflexion-sur-la-taille-de-liv

En résumé, il existe plusieurs façons de deviner un mot de passe WEP : 
- Avec un grand nombre d'IV (l'IV étant une clé permettant de dériver la passphrase). Pour cela, il est nécessaire d'avoir au minimum 2^12 IV, car il y a un risque de collisions.
- En créant un script de résolution à partir d'un IV, d'un challenge et d'une réponse,
- En faisant une attaque par dictionnaire.

Si vous choisissez de faire une attaque par dictionnaire, je vous conseille de tester les wordlists de SecLists, le bon dictionnaire se trouve à la racine de Passwords : https://github.com/danielmiessler/SecLists/tree/master/Passwords


{{< /tab >}}

{{< tab "Niveau 2" >}}
Création d'une wordlist de batard grâce aux indices sur le forum (tous les wordlistes qui commencent par d de seclists/Passwords):
```sh
cat /usr/share/wordlists/seclists/Passwords/d* >> wordlists-d.txt
```

> Je vous l'accorde, la wordlist n'est pas facile à trouver. Sans les indices, cela me paraît impossible. Le challenge nous incite à créer un script de résolution plutôt que faire l'attaque par dictionnaire.

La longueur de cette wordlist devrait être de 11937011 lignes.

On suppose que la clé ne peut être que 64 car on sait que une clé WEP fait 64 ou 128 bit. Une clé 128 serait trop longue à cracker pour un challenge.
Le BSSID peut être récupérer dans Wireshark ou avec aicrack-ng.

```sh
aircrack-ng -w wordlists-d.txt -b 00:0F:B5:56:E0:9E -n 64 ch10.cap
```

{{< /tab >}}{{< /tabs >}}
