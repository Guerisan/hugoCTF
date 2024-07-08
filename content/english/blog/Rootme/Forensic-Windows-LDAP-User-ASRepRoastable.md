---
title: Root-me - Windows - LDAP User ASRepRoastable
meta_title: ""
description: Trouvez l'utilisateur vulnérable à AsRepRoastable.
date: 2024-08-07T05:00:00Z
image: /images/rootme_logo.png
categories:
  - Forensic
  - Moyen
author: Emma.exe
tags:
  - Forensic
  - Rootme
draft: false
---

Le challenge se présente sous la forme d'un JSON qui a été généré grâce à ldap2json : https://github.com/p0dalirius/ldap2json.

On nous demande de trouver le mail de l'utilisateur vulnérable à l'attaque ASRepRoastable.

## Principe de l'attaque

Dans un premier temps, qu'est-ce que l'attaque AS_REP Roasting ?

Par défaut, lorsque l'on demande un TGT auprès du KDC, l'utilisateur doit avant tout s'authentifier. Cependant si l'option "Do not require Kerberos preauthentification" est cochée pour un compte utilisateur, cela permet à un attaquant de récupérer des TGT pour cet utilisateur.
Vu que le TGT contient le mot de passe de l'utilisateur, un attaquant peut le récupérer et se connecter au compte utilisateur.

Cette option est rarement cochée dans la réalité puisqu'elle n'est pas par défaut mais il est important d'apprendre à repérer ces comptes à risque. Et accessoirement c'est le but du challenge. 

## Résolution du challenge

Pour la résolution de ce challenge je vous propose deux niveaux d'aide : 
- Le premier niveau sous la forme d'indices et de ressources à explorer pour résoudre le challenge, sans pour autant donner la solution
- Le deuxième niveau qui présente un exemple de résolution.

{{< notice "tip" >}} Essayez de ne pas regarder la solution si vous voulez vraiment progresser. Une fois le challenge résolu, il peut être intéressant de la regarder pour apprendre de nouvelles techniques ! {{< /notice >}}

{{< tabs >}} {{< tab "Niveau 1" >}}

Avant de commencer à résoudre le challenge, je vous propose un peu de lecture.
Tout d'abord cet article sur l'explication de l'AS_REP Roasting plus en détail : https://beta.hackndo.com/kerberos-asrep-roasting/ et celui-ci : https://www.it-connect.fr/securite-active-directory-comprendre-et-se-proteger-attaque-asreproast/
Dans ces documentations, tentez de trouver quel attribut est utile pour détecter l'AS-REP Roasting.

Ensuite, tentez de comprendre comment fonctionne la valeur de cet attribut (la documentation de Microsoft est utile dans ce cas) et comparez avec la valeur que vous trouvez généralement dans l'AD du challenge.

Quelle est la valeur que vous devez chercher ?

{{< /tab >}}

{{< tab "Niveau 2" >}}
Si le compte est ASRepRoastable, cela se voit dans l'attribut `userAccountControl`.
Il faut ensuite se référer à la documentation de Microsoft pour calculer la valeur de ce dernier : https://learn.microsoft.com/fr-fr/troubleshoot/windows-server/active-directory/useraccountcontrol-manipulate-account-properties

Ce qu'il faut retenir quant à la valeur d'userAccountControl, c'est que les différentes propriétés du compte possèdent une valeur numérique qui **s'additionnent entre elles**.
Si l'on regarde la valeur classique d'un compte dans ce domaine, on trouve **66048**. 
Cela doit sûrement correspondre au valeur de DONT_EXPIRE_PASSWORD (65536) + NORMAL_ACCOUNT (512).

Si on considère que le compte possédant l'ASREP est conçu de la même manière que les autres, on ajoute 4194304 conformément à ce qui est indiqué dans la documentation de Microsoft pour la ligne **DONT_REQ_PREAUTH**.
Le calcul à faire est donc : **DONT_EXPIRE_PASSWORD (65536) + NORMAL_ACCOUNT (512) + DONT_REQ_PREAUTH (4194304)**.
Cela nous donne un résultat de **4260352**.

On recherche par exemple avec `ldap2json` cette valeur :
```sh
[]> object_by_property_value 4260352
[CN=Fitzgerald,CN=Users,DC=ROOTME,DC=local] => userAccountControl
 - 4260352
```

Et on trouve le compte qui est concerné par ce paramètre.
Il ne reste plus qu'à trouver son mail pour obtenir le flag !
  
{{< /tab >}}
{{< /tabs >}}
