---
title: Rootme - Retour au collège
meta_title: ""
description: this is meta description
date: 2024-04-04T05:00:00Z
image: /images/rootme_logo.png
categories:
  - Rootme
  - Facile
author: Alexis
tags:
  - programmation
  - réseau
draft: false
---

# Niveau 0
Ce challenge permet de pratiquer la connexion à une socket réseau et faire des calculs simples.

# Niveau 1
Pour résoudre ce challenge, les librairies "socket" et "math" de Python peuvent être utiles.
Les étapes du challenge :
- Se connecter à la socket réseau
- Récupérer les deux nombres
- Faire le calcul
- Envoyer le résultat

# Niveau 2
Les étapes du programme à faire sont données dans l’énoncé du challenge :
- Se connecter à un programme sur une socket réseau
- Vous devez calculer la racine carrée du nombre n°1 et multiplier le résultat obtenu par le nombre n°2.  
- Vous devez ensuite arrondir à deux chiffres après la virgule le résultat obtenu.  
- Vous avez 2 secondes pour envoyer la bonne réponse à partir du moment où le programme vous envoie le calcul.  
- La réponse doit être envoyée sous la forme de int ou float

## Se connecter à un programme sur une socket réseau
### Connexion au challenge
``` python
server = "challenge01.root-me.org"
port = 52002

#init connection
sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sock.connect((server,port))
```
### Récupération des informations du challenge
``` python
#get values of the chall
data = sock.recv(4096).decode()
print(data)
```
 On obtient ceci :
``` python

====================
 GO BACK TO COLLEGE
====================
You should tell me the answer of this math operation in less than 2 seconds !

Calculate the square root of 627 and multiply by 1139 =
```
## Calculer le résultat
### Extraire les nombres 
Pour faire des opérations sur les nombres, on a besoin de savoir les extraire de l'énoncé. Pour cela on va s'appuyer le texte autour des nombres :
- Le premier nombre est précédé de "the square root of " et suivi d'un espace " "
- Le deuxième nombre est précédé de "and multiply by " et suivi d'un espace " "

En python on peut utiliser la fonction "split" qui permet de découper une chaîne de caractère en fonction d'un délimiteur
``` python
#Extract values
first_num = int(data.split("the square root of ")[1].split(" ")[0])
second_num = int(data.split("and multiply by ")[1].split(" ")[0])
```
Il ne faut pas oublier de convertir chaque nombre en un entier avec int()
### Faire le calcul
#### Racine carrée du nombre n°1
``` python 
math.sqrt(first_num)
```
#### Multiplier le résultat par le nombre n°2
``` python
math.sqrt(first_num)*second_num
```
#### Arrondir à deux chiffres après la virgule
``` python
round(math.sqrt(first_num)*second_num,2)
```

## Envoyer la réponse
``` python
sock.send(f"{result}\r\n".encode())
```
Ne pas oublier le "\\r\\n"

### Récupérer le flag
``` python
data = sock.recv(4096).decode()
print(data)
```

