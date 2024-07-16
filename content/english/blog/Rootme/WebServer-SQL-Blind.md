---
title: Root-me - SQL Injection - En aveugle
meta_title: ""
description: Récupérer le mot de passe administrateur en effectuant une injection SQL.
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

# Introduction

Le but de ce challenge est de récupérer le mot de passe administrateur en effectuant une injection SQL.
Comme l'indique le titre, il s'agit d'une injection à l'aveugle (blind). Cela arrive lorsqu'une application web est vulnérable aux attaques par injection SQL mais qu'elle n'affiche ni d'erreur ni le retour des requêtes. 

Pour la résolution de ce challenge je vous propose deux niveaux d'aide : 
- Le premier niveau sous la forme d'indices et de ressources à explorer pour résoudre le challenge, sans pour autant donner la solution
- Le deuxième niveau qui présente un exemple de résolution.

{{< notice "tip" >}} Essayez de ne pas regarder la solution si vous voulez vraiment progresser. Une fois le challenge résolu, il peut être intéressant de la regarder pour apprendre de nouvelles techniques ! {{< /notice >}}

## Résolution

{{< tabs >}} {{< tab "Niveau 1" >}}

Dans un premier temps, voici une documentation sur les Blind SQLi : https://portswigger.net/web-security/sql-injection/blind

Dans un second temps, je vous conseille de regarder le fonctionnement de sqlmap.
Il est possible de résoudre ce challenge sans cet outil, mais cela est plus compliqué.

La dernière information à acquérir est celle du paramètre injectable. 
Pour cela, je vous conseille de parcourir le site avec Burp, récupérer les requêtes avec des paramètres et les passer à Sqlmap afin de les tester.

{{< /tab >}} {{< tab "Niveau 2" >}}

On récupère la requête de login, qui contient les paramètres username et password avec Burp.
On les passe à sqlmap afin de tester s'ils sont injectables : 
```sh
sqlmap -r post.txt
```

Le fichier post.txt contient la requête copier/coller de Burp.
D'après sqlmap, les paramètres username et password semblent être injectables.
On lance donc le dump de la base :
```sh
sqlmap -r post.txt -p username --dump
```
Cela peut prendre beaucoup de temps mais on finit par obtenir le mot de passe Administrateur.

{{< /tab >}}{{< /tabs >}}
