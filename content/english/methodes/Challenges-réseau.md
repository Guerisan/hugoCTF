---
title: Fiche méthode - Réseau
meta_title: ""
description: Comment aborder un challenge réseau ?
date: 2024-18-07T05:00:00Z
image: /images/wireshark.png
categories:
  - Méthodes
author: Emma.exe
tags:
  - Méthodes
  - Fiches
  - Réseau
  - Wireshark
  - Capture réseau
draft: false
---


## Introduction
Cette fiche a pour but de répondre à la question : Comment aborder un challenge réseau ?

Tout d'abord quelques prérequis aux challenges réseau : 
- **Connaitre les couches du modèle OSI**. En effet, connaître les couches du modèle OSI (ou du modèle TCP/IP) permet d'avoir une base solide quant à l'appréhension de nouveaux protocoles. Cela permet de savoir rapidement quelles informations on peut extraire à quel niveau. Avoir une compréhension globale du réseau permet un accès garanti à la réussite de la plupart des challenges.
- **Savoir analyser une trame/un paquet**. Par exemple, être capable de retrouver des informations dans une trame Ethernet (retrouver la MAC de destination/source...). Être familier avec ce travail permet de mieux s'y retrouver au moment de l'analyse de trame/paquets.


## Forme du challenge

La première question à se poser lors de la résolution d'un challenge réseau est : "A quoi ressemble le challenge et quels types de fichiers ai-je à faire ?"

Généralement, les challenges sont de la forme d'une capture réseau à analyser, à l'exception des challenges de radiofréquences, qui sont souvent au format wav.

Commençons par les captures réseau.

### Capture réseau

Vous êtes dans le cas où le challenge s'agit d'un fichier avec l'extension cap, pcap ou pcapng.

Pour cela, plusieurs outils peuvent être utilisés pour visualiser ces trames : Wireshark, tcpdump, ettercap, tshark ou encore NetworkMiner.

#### Wireshark

Wireshark est un outil ayant l'avantage de posséder une interface graphique.
Il permet d'analyser les trames manuellement. Il est sûrement le plus facile à prendre en main.
Cependant, il n'est pas idéal lorsqu'il s'agit d'automatiser le traitement de trames.

##### Présentation générale

Wireshark se présente en plusieurs fenêtres : 
- La première celle du dessous, présente toutes les trames qui sont présentes dans la capture. Cela permet d'avoir une vision générale de l'échange qui a eu lieu.
- En bas à gauche, nous pouvons visualiser les détails d'une trame sélectionnée. On peut lire tous les champs interprétés.
- En bas à droite, Wireshark nous présente le dump de la trame en brute, tel quel a été reçu.
{{< image src="images/wireshark-1.png" caption="" alt="" height="" width="" position="center" command="fill" option="q100" class="img-fluid" title="image title" webp="false" >}}

##### Filtre 
Wireshark possède sa propre syntaxe pour filtrer les trames et n'afficher que celle qui nous intéresse.

Afficher toutes les trames ayant l'IP `10.20.144.150` (indifféremment source ou destination) :

{{< image src="images/wireshark-4.png" caption="" alt="" height="" width="" position="center" command="fill" option="q100" class="img-fluid" title="image title" webp="false" >}}

Idem mais en spécifiant IP source :

{{< image src="images/wireshark-3.png" caption="" alt="" height="" width="" position="center" command="fill" option="q100" class="img-fluid" title="image title" webp="false" >}}

Afficher toutes les trames utilisant le protocole Telnet (port 23) :
{{< image src="images/wireshark-5.png" caption="" alt="" height="" width="" position="center" command="fill" option="q100" class="img-fluid" title="image title" webp="false" >}}

Utilisation des opérateurs logiques ET et OU pour ajouter des filtres : 
{{< image src="images/wireshark-6.png" caption="" alt="" height="" width="" position="center" command="fill" option="q100" class="img-fluid" title="image title" webp="false" >}}

{{< image src="images/wireshark-7.png" caption="" alt="" height="" width="" position="center" command="fill" option="q100" class="img-fluid" title="image title" webp="false" >}}
##### Récupérer des fichiers

Wireshark permet aussi, dans certains de récupérer des fichiers qui ont été transféré.
Pour cela, cliquer sur **Fichier > Exporter Objets** puis sélectionnez le protocole qui vous intéresse.
Une nouvelle fenêtre s'ouvre et vous pouvez voir tous les objets que Wireshark a pu récupérer.
Vous pouvez les télécharger pour les analyser.

Exemple avec le protocole HTTP :
{{< image src="images/wireshark-8.png" caption="" alt="" height="" width="" position="center" command="fill" option="q100" class="img-fluid" title="image title" webp="false" >}}

{{< notice "warning" >}} Téléchargez toujours les fichiers dans une machine virtuelle, isolée de votre ordinateur personnel. Les captures réseau peuvent contenir des virus. {{< /notice >}}

##### Déchiffrer le trafic avec une clé 
En ajoutant la clé de déchiffrement à Wireshark, cela permet d'analyser la trame en clair. Wireshark est capable de déchiffrer le trafic s'il possède cette clé. Cette clé peut par exemple être récupéré depuis l'exportation d'objet comme vu précédemment.

Afin d'ajouter la clé privée à Wireshark, allez dans **Editer > Préférences** puis déployer l'onglet **Protocols** : 
{{< image src="images/wireshark-10.png" caption="" alt="" height="" width="" position="center" command="fill" option="q100" class="img-fluid" title="image title" webp="false" >}}

Sélectionnez ensuite **TLS** et modifiez la liste des clés RSA : 

{{< image src="images/wireshark-9.png" caption="" alt="" height="" width="" position="center" command="fill" option="q100" class="img-fluid" title="image title" webp="false" >}}

Ajoutez votre clé RSA en spécifiant le chemin vers la clé au format pem : 
{{< image src="images/wireshark-11.png" caption="" alt="" height="" width="" position="center" command="fill" option="q100" class="img-fluid" title="image title" webp="false" >}}

Vous pouvez ajouter l'ip et le port concerné, mais cela est facultatif.
Validez, retournez vers le trafic. Il est désormais en clair.

###### Quand l'utiliser ?

- Lorsque vous avez besoin d'une interface graphique pour une analyse manuelle
- Pour l'extraction d'objets et le déchiffrement des flux de façon simplifié
- Pour des analyses simples qui ne nécessitent pas d'automatisation

#### Tcpdump
Tcpdump est un outil en ligne de commande, très utile pour capturer et analyser le réseau.
Voici quelques commandes basiques pour commencer : 

Lire et afficher un fichier pcap : 
```sh
tcpdump -r fichier.pcap
```

Afficher les 10 premiers paquets : 
```sh
tcpdump -r fichier.pcap -c 10
```

Filtrer les paquets par hôte : 
```sh
tcpdump -r fichier.pcap host 192.168.1.1
```

Filtrer sur le port : 
```sh
tcpdump -r fichier.pcap port 80
```

Filtrer sur le protocole : 
```sh
tcpdump -r fichier.pcap tcp
```

L'avantage de TCPDump est qu'il peut être combiné à d'autres outils tel que grep, sed... afin de filtrer la sortie et ainsi extraire la valeur d'un champ précis, dans tous les paquets de la capture.

###### Quand l'utiliser ?

- Pour des captures rapides et légères du réseau.
- Pour les analyses basiques où la simplicité et la rapidité sont prioritaires.
- Lorsque vous avez besoin de capturer les paquets pour une analyse ultérieure. 

#### Ettercap

Ettercap est un autre outil en ligne de commande, cette fois-ci orienté pour faire du Man-in-the-Middle.
Il offre une plus grande flexibilité dans l'analyse que TCPdump grâce à sa syntaxe. Il est plus facile de combiner différents filtres. De plus, il est capable d'extraire les hashes : 

###### Commandes basiques

```sh
ettercap -Tqr fichier.cap
```

Filtrer sur l'IP : 
```sh
ettercap -T -r fichier.pcap -F 'ip.src == 192.168.1.1 || ip.dst == 192.168.1.1'
```

Filtrer sur le port : 
```sh
ettercap -T -r fichier.pcap -F 'tcp.port == 80'
```

Filtrer sur le protocole : 
```sh
ettercap -T -r fichier.pcap -F 'arp'
```

Tout comme `tcpdump`, il peut être combiné à `grep`, `sed`, `awk`... afin de trier la sortie et extraire la donnée intéressante.

###### Quand l'utiliser ?

- Lorsque vous avez besoin d'intercepter, de modifier ou d'injecter du trafic réseau
- Pour les analyses réseau spécifiques aux attaques MiTM (ex : WiFi).

#### Tshark

Tshark est l'outil en ligne de commande de Wireshark.
Il utilise les mêmes filtres que Wireshark.

###### Commandes utiles

Lire un fichier pcap :
```sh
tshark -r fichier.pcap
```

Ajouter un filtre : 
```sh
tshark -r fichier.pcap -Y "tcp.port == 80"
```

Afficher au format ASCII :
```sh
tshark -r fichier.pcap -x
```

Sauvegarder les paquets filtrés dans un nouveau fichier : 
```sh
tshark -r fichier.pcap -Y "tcp.port == 80" -w fichier_filtre.pcap
```

Afficher des statistiques des conversations TCP :
```sh
tshark -r fichier.pcap -q -z conv,tcp
```

###### Quand l'utiliser ?

- Lorsque vous avez besoin d'une analyse profonde et détaillée des paquets
- Lorsque vous souhaitez bénéficier de la puissance de Wireshark en mode ligne de commande
- Lorsque vous travaillez avec un grand nombre de protocoles


#### NetworkMiner

NetworkMiner est un outil graphique qui sert à extraire des artefacts, comme des fichiers, des images, des mails et des mots de passe depuis des capture réseau PCAP.
Source : https://www.netresec.com/?page=NetworkMiner

L'outil se présente sous plusieurs onglets, en fonction de ce qu'a été capable d'extraire NetworkMiner :
{{< image src="images/networkminer.png" caption="" alt="" height="" width="" position="center" command="fill" option="q100" class="img-fluid" title="image title" webp="false" >}}

###### Quand l'utiliser ?
 - Pour analyser du trafic en clair, rapidement mais peu détaillé
 - Pour retrouver des artéfacts (fichiers, images)
 - Pour récupérer certains hashes ou credentials 

### Radiofréquences

A venir...

### Conseils généraux

Lorsque vous analyser une capture réseau, si le nom du challenge est explicite, le protocole à analyser est normalement assez évident.
Assurez-vous de comprendre le fonctionnement de ce protocole dans les détails, en lisant de la documentation, tel que les RFC.

Renseignez-vous sur les attaques courantes sur ce type de protocole. Vous pouvez directement éliminer celle qui nécessite une interaction avec la cible.

Une fois que vous avez une idée de l'attaque qu'il faut mener, n'hésitez pas à consulter Github afin de voir s'il existe déjà quelqu'un qui aurait fait un script, que vous pouvez adapter pour le challenge.
