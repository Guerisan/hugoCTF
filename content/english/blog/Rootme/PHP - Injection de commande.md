---
title: PHP - Injection de commande
meta_title: ""
description: this is meta description
date: 2024-05-06T05:00:00Z
image: /images/rootme_logo.png
categories:
  - Rootme
  - Facile
author: Professeur_Jack
tags:
  - web-server
  - php
draft: false
---
## Back-end non-sécurisé

Ce challenge d'introduction démontre les dangers à ne pas mettre de protection côté serveur.
C'est un exemple type de **"ne jamais faire confiance à l'utilisateur"** .

Notre point d'entrée est ici un service accessible par une interface web, qui propose d'entrer une ip sur laquelle utiliser un service *ping*. Une fonctionnalité innocente de mesure du temps de réponse du host renseigné.
{{< image src="images/php-injection/php-1.png" caption="Le début des ennuis" alt="Une page web contenant un formulaire simple permettant d'entrer une ip. La page affiche ensuite la sortie d'une commande ping de l'ip renseignée" height="" width="" position="center" command="fill" option="q100" class="img-fluid" title="image title" webp="false" >}} 

Le back-office (réalisé en php d'après le nom du challenge), doit utiliser une fonction du language comme `shell_exec()`, qui permet d'exécuter une commande shell (typiquement *bash*) sur la machine hôte et d'en récupérer la sortie, ici un simple ping.

**Mais que se passe-il si on entre plus d'informations que prévu ?**

## Injection
Si on part du principe que le contenu est envoyé tel quel, on peut tenter d'utiliser la syntaxe bash pour envoyer des commandes supplémentaires.
Typiquement `&&` pour envoyer une commande à la suite, ou un simple `;`.

On peut tenter par exemple de lister les fichiers à l'emplacement de l'exécution de commande avec `ls`

```bash
127.0.0.1 ; ls -la #pour afficher également les fichiers cachés
```

Et effectivement, le site affiche un nouvel output :

{{< image src="images/php-injection/php-2.png" caption="Visiblement, pas de protection côté server" alt="Une page web contenant un formulaire simple permettant d'entrer une ip. La page affiche ensuite la sortie d'une commande ping de l'ip renseignée" height="" width="" position="center" command="fill" option="q100" class="img-fluid" title="image title" webp="false" >}} 

Il n'y a plus qu'à utiliser les bonnes commandes pour lire le contenu des fichiers et essayer d'en apprendre plus...

{{< button label="Entrez le flag pour la solution complète" class="level-3" link="/" style="solid" >}}