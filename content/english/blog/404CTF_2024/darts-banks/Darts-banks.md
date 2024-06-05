---
title: 404 CTF - Darts Banks
meta_title: ""
description: Write-up forensic inspection de paquets réseau
date: 2024-04-04T05:00:00Z
image: /images/404CTF_logo.png
categories:
  - 404CTF
  - moyen
author: Prof_Jack
tags:
  - wireshark
  - forensic
  - réseau
draft: false
isSecret: false
---

Ce challenge du 404CTF a été un très bonne introduction sur l'utilisation de Wireshark pour détecter les anomalies dans les trames réseau.

## Le pitch :

*Un utilisateur s'est fait voler des secrets en se connectant à son site de fléchettes préféré, alors que sa connexion était sécurisée.
Il pense cependant qu'il s'est passé des choses étranges sur le réseau pendant son absence, et nous fournit un fichier pcapng pour essayer d'en savoir un peu plus...*

{{< button label="Télécharger la capture" link="/dart-banks/dart.pcapng" style="solid" >}}

## Première étape : inspection de la capture.
A l'inspection dans **Wireshark**, le premier élément qui nous saute aux yeux est celui-ci :
{{< image src="images/dart-banks/darts-1.png" caption="Quelqu'un a fait une mauvaise requête..." alt="wireshark capture" height="" width="" position="center" command="fill" option="q100" class="img-fluid" title="image title" webp="false" >}} 

La requête HTTP malformée nous indique une chose : quelqu'un essayé de se connecter manuellement à l'url d'une machine présente sur le même sous-réseau, la **192.168.78.89**.
Il a échoué une première fois avant de recommencer avec succès.
Qui plus est, depuis un terminal **Powershell** comme les entêtes nous en informent :
{{< image src="images/dart-banks/darts-2.png" caption="Voilà qui ne sent pas bon." alt="wireshark capture" height="" width="" position="center" command="fill" option="q100" class="img-fluid" title="image title" webp="false" >}} 

Cette requête récupère un ensemble de *segments tcp*  qui serviront à reconstituer ce qui semble être un script powershell encodé en *base64*. 
On a alors de bonnes raisons de penser qu'il s'agit là de notre point d'injection, et que quelqu'un a mis la main sur la machine de notre passionné de fléchettes pendant son absence...
{{< image src="images/dart-banks/darts-3.png" caption="Le début des ennuis" alt="wireshark capture" height="" width="" position="center" command="fill" option="q100" class="img-fluid" title="image title" webp="false" >}} 

Grâce à Wireshark, on peut facilement récupérer le script en entier en tant qu'objet HTTP, ainsi que les suivant s'il y en a.
`Fichier -> Exporter Objets -> HTTP`
Le plus gros, c'est notre notre script powershell encodé, récupéré avec le **GET** initial.
Mais on remarque une série d'objets venant de requêtes **POST** par la suite.
Il y a donc à parier que le script powershsell met en place un mécanisme d'exfiltration, vers la même machine depuis laquelle il a été téléchargé.
{{< image src="images/dart-banks/darts-4.png" caption="Le début des ennuis" alt="wireshark capture" height="" width="" position="center" command="fill" option="q100" class="img-fluid" title="image title" webp="false" >}} 

L'objet en notre possession, on peut commencer à l'analyser.