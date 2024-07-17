---
title: Root-me - XSS - Server Side
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
  - XSS
draft: false
---

# Introduction

Pour ce challenge, nous allons devoir réaliser une XSS qui s’exécutera côté du serveur. 
Il suffit de prendre en main l'application et d'essayer tous les champs. 
L'application qui nous est proposée est un générateur de certification de message. 

Ce write-up sera en deux parties. 
La première ne contiendra que des hints et aucune solution, contrairement à la seconde. 

{{< tabs >}} {{< tab "Niveau 1" >}}
- Que fait réellement l'application ? HTML to PDF ? 
- Vous avez testé tous les champs utilisateurs ? Vraiment tous ? 
- Vous avez bien lu la description du challenge ? 
- Qu'est-ce qui est Sanitize ? qu'est-ce qui ne l'est pas ? 
- Une XSS, c'est toujours du JS ? 
- Vous avez essayé de regarder des techniques sur Internet ? 

{{< /tab >}}

{{< tab "Niveau 2" >}}

Lorsque je suis bloqué, j'effectue en générale des recherches sur les techniques qui existe sur la vulnérabilité que j'essaye d'exploiter. 

L'une des sources que j'ai visitée, m'invitait à injecter des balises html. 

Dans cette application, seuls les champs last name et first name semble vulnérable. 

En injectant `<h1>r3dbucket</h1>` dans ces derniers, nous obtenons bien un titre de niveau 1 dans notre pdf. 

Tout le reste semble sanitize, comme les balises `<script>`. 

Nous allons devoir nous débrouiller avec les balises html. 

Soit vous avez déjà des connaissances en HTML, ou vous avez lu la doc et vous savez ce qu'il faut utiliser. Soit vous avez déjà lu un exemple de ce style. 

Il existe en effet la balise `iframe` qui permet d'intégrer un contenu externe à la page que nous allons générer, en l’occurrence un pdf. 

Si j'essaye le payload suivant : 

```bash
<iframe src=/flag.txt width=300 height=200>
```

Je pourrais récupérer le contenu de flag.txt 

{{< /tab >}}
{{< /tabs >}}

