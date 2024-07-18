---
title: RF - FM Transmission
meta_title: ""
description: Premier challenge RootMe sur les RadioFréquences
date: 2024-07-18T8:00:00Z
image: /images/rootme_logo.png
categories:
  - Rootme
  - Facile
author: Professeur_Jack
tags:
  - radio
  - gqrx
draft: false
---
# Décodage d'une transmission FM
**Le pitch** :
Pour ce challenge, nous avons sous la main une *lourde capture brute* échantillonnée sur **8Mbs**.
Son poids décompressé de 2.1Go ne va pas rendre son analyse confortable.

## FM, AM, quelle différence ?
On a l'indice que ce signal a été transmis en **Modulation de Fréquence**, c'est-à-dire modulé avec une porteuse en jouant sur la **fréquence** du signal plutôt que son **amplitude**.

{{< image src="images/radio-2/Amfm3-en-de.gif" caption="Une comparaison des signaux AM et FM" alt="Une comparaison entre des signaux AM et FM" height="" width="" position="center" command="fill" option="q100" class="img-fluid" title="image title" webp="false" >}} 

Utilisée pour des signaux de fréquences généralement plus élevés que la AM, la FM a l'avantage de moins subir les interférences et de profiter d'une meilleure qualité de son en raison d'une bande passante plus large.
Elle est moins sensible au "bruit" (parasites), du fait de la variation de fréquence (contrairement à l'amplitude).

En revanche, les circuits utilisés sont plus complexes, et le signal ne traversera pas facilement les obstacles physiques. L'emploi de fréquences élevées ne permettra pas non plus de communiquer sans relais *au -delà de la courbure de la Terre* : ces ondes-ci rebondissent difficilement sur la ionosphère.

## L'analyse d'un signal :
Ce type de capture ayant été fait sur une certaine largeur de bande, il est bien possible qu'elle contienne plus que la simple information qui nous intéresse.

On le constate facilement à l'aide d'un outil comme **GQRX**, qui permet d'afficher un **waterfall** donnant un retour visuel des bandes utilisées dans la durée :

{{< image src="images/radio-2/waterfall.png" caption="Un waterfall sur gqrx" alt="Un waterfall sur gqrx" height="" width="" position="center" command="fill" option="q100" class="img-fluid" title="image title" webp="false" >}} 

Si on promène la zone à démoduler sur la bande passante (*barre rouge entourée d'un filtre dans la partie graphique*), on se rend compte qu'un de ces signaux semble nous donner des informations audio !

Mais sans traitement auditif, difficile d'entendre quoi que ce soit.

Il nous faudra jouer sur :
- L'**échantillonnage** à l'ouverture du fichier (on sait que c'est 8Mb/s),
- La largeur et la position du **filtre**,
- Le mode de démodulation (le plus important),
- L'**AGC** (Contrôle Automatique de Gain)
- Le **Squelch** pour réduire le bruit de fond

On oubliera pas de laisser *Throttle* à `true`, dans le cas contraire le CPU risque de chercher à traiter le signal le plus vie possible, bien en dehors des conditions de réception normales !

{{< button label="Entrez le flag pour une solution complète ;-)" class="level-3" link="/" style="solid" >}}
