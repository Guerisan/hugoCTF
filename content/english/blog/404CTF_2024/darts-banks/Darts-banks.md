---
title: 404 CTF - Darts Banks
meta_title: ""
description: this is meta description
date: 2024-04-04T05:00:00Z
image: /images/404CTF_logo.png
categories:
  - 404CTF
  - moyen
author: Prof_Jack
tags:
  - wireshark
  - réseau/images/image-placeholder.png
  - forensic
draft: false
isSecret: false
---

Ce challenge du 404CTF a été un très bonne introduction sur l'utilisation de Wireshark pour détecter les anomalies dans les trames réseau.

## Le pitch :

*Un utilisateur s'est fait voler des secrets en se connectant à son site de fléchettes préféré, alors que sa connexion était sécurisée.
Il pense cependant qu'il s'est passé des choses étranges sur le réseau pendant son absence, et nous fournit un fichier pcapng pour essayer d'en savoir un peu plus...*

{{< button label="Télécharger la capture" link="/dart-banks/dart.pcapng" style="solid" >}}

## Première étape : inspection de la capture.
A l'inspection, le premier élément qui nous saute aux yeux est celui-ci :
{{< image src="images/dart-banks/darts-1.png" caption="Quelqu'un a fait une mauvaise requête..." alt="wireshark capture" height="" width="" position="center" command="fill" option="q100" class="img-fluid" title="image title" webp="false" >}} 

