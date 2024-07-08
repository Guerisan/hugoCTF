---
title: 404 CTF - De la fiture sur la ligne
meta_title: ""
description: Reconstitution d'une image à partir de morceaux séparé
date: 2024-07-08T05:00:00Z
image: /images/404CTF_logo.png
categories:
  - 404CTF
  - facile
author: Bafrac
tags:
  - programmation
  - Python
draft: false
isSecret: false
---

# Le pitch
Un programme divise une image en 7, distribuant un bit à la fois à chaque fichiers, mais le 4ème fichier a eu un problème et ne contient rien de bon, reconstituez l'image. Le fichier numéro 8 contient le bit de parité des 7 bits précedents.

{{< button label="Télécharger le challenge" link="/De_la_friture_sur_la_ligne/friture.zip" style="solid" >}}


# Première étape: Comprendre le problème
Dans le challenge, on reçoit un programme python, montrant comment l'image est prise en argument, divisé en 8 après un encodage qui est l'ajout d'un bit de parité. Il faut créer un programme qui reconstitue l'image à partir des fichiers données mais sans le quatrième fichier qui est corrompus (oups :/)

# Deuxième étape: le bit de parité
Pour reconstituer l'image, il faut prendre le n ème bit des 7 premiers fichiers et les mettre ensemble, ce qui n'est pas directement possible car il nous manque un fichier.
Le bit de parité est un moyen de confirmer si un série de bit est celle attendu, pour le déterminer il faut additionner tout les bit qui servent à la création de ce bit de parité (par exemple le premier bit de chaque fichier) et faire modulo 2 à ce résultat qui sera donc 1 ou 0. On a donc un moyen de détecter si 1 bit est différent de l'état initial.
L'objectif de ce challenge est de réaliser que l'on peut reconstruire l'image en calculant les bits dans le fichier 4 en calculant la bit de parité dans le fichier 4, si la calcul est différent de ce qui est dans le fichier 8 il faut mettre 1 à ce bit pour le fichier 4, sinon 0.


# Troisième étape: création du programme
Bien que le programme peut être fait dans une multitude de langage, le début de programme sera fait en python, car rapide, efficace et celui de l'énoncé. Voici un schéma de ce à quoi le programme peut ressembler, la taille des fichiers est la même.:

-récuperer toutes les données des 8 fichiers dans une liste par exemple

-pour chaque nème bit de tout les fichiers, faire la somme (sauf le fichier 4) et comparer avec le fichier 8, si le résultat est égal, mettre 0 à cet emplacement du fichier 4, sinon mettre 1

-Fusionner les listes 

-Retirer la 8ème liste si non fait avant

-S'assurer que le résultat à de groupes de 8bits

-Exporter le résultat sous forme d'image png



