---
title: HackTheBox - Perfection:Level2 
meta_title: ""
description: this is meta description
date: 2024-05-28T05:00:00Z
image: /images/Perfection.png
categories:
  - HackTheBox
  - Facile
author: Tmax
tags:
  - web
  - SSTI 
  - brute-force
draft: false
---

# HackTheBox - Perfection:level2 

Cette box, de difficulté **Easy**, nous plonge dans une **application web en Ruby** qui hébérge une application _"créée par des étudiants"_. 

Pour la solve, elle nécessitera des compétences en : 

- Enumeration
- SSTI
- Brute-force

# Comment aborder cette box ? 

Dans cette partie nous aborderons toutes les compétences nécessaires pour réaliser cette box, avec des pistes et des indications pour ceux qui le souhaite. 

Vous pouvez néanmoins essayer de la solve seul(e), et trouver l'indication qui vous débloquera ici. 

## USER : Enumeration

### Port

En utilisant NMAP, nous pouvons avoir plus d'informations sur le serveur auquel nous avons à faire. 

### Web

Il est parfois utile d'utiliser des outils qui permettent de connaitre les technologies utilisées des sites sur lesquels on navigue. 

## USER : Exploitation de la vulnérabilité

Pour cette étape, vous devrez avoir réalisé l'étape précédente. Ainsi, lorsqu'une application interprète des champs altérables par l'utilisateur, il y de grandes chances que ce soit essentiel pour l'exploitation. Peut-être devriez vous essayer d'injecter des inputs triviaux dans tous les champs afin de valider si votre input est interprété. 

## ROOT : Enumeration

Lorsque l'on cherche à privesc, on effectue généralement ue recherche de fichiers en fonction de leurs permissions ou d'un indice que nous avons en notre possession comme un nom ou un pseudo. 

## ROOT : Exploitation 

Afin de réaliser un brute-force, il existe plusieurs outils pour cela et donc plusieurs tutoriels qui peuvent être disponible sur internet. 

Néanmoins, il est également possible de scripter son propre outil pour brute-force un hash. 