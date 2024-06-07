---
title: Énumération Box "boot-to-root"
meta_title: ""
description: Article d'aide pour la première approche des box de type boot to root
date: 2024-04-04T05:00:00Z
image: /images/born-to-be-root.jpg
categories:
  - Méthodes
author: Tmax
tags:
  - Méthodes
  - Fiches
draft: false
---

Dans cet article, vous retrouvez un condensé des différentes phases types que vous pourrez rencontrer durant vos sessions HackTheBox. 

C'est une sorte d'idéal pour les personnes qui souhaient commencer mais qui n'ont pas l'habitude des modes opératoires utilisés. 

## Énumération

Commencez par ajouter l'IP de la cible dans /etc/hosts. 

L'énumération est une étape importante de reconnaissance initiale. Elle permet de pouvoir comprendre les services hébergés par la machine auditée. L'objectif et de reccueillir le maximum d'information accessible sans exploitation particulière.  
### Ports

Pour énumérer les ports d'une machine, on utilise souvent le binaire `nmap`.

Les options Intéréssantes pour le CTF sont les suivantes : 

```bash
-p- # pour effectuer une recherche sur les ports 1 à 65535

-sC # pour utiliser les scripts de scan

-O  # pour la découverte de l'OS 

-V # pour les numéros de version

-A # active la detection de l'OS, de la version, l'utilisation des scripts ainsi que de traceroute

-sV # déterminer les informations relatives au service/à la version par port

-sn # Pas de scan de port, seulement ping
```

Quant aux autres options, rien de tel que le manuel pour en savoir plus. Il a l'avantage d'être très clair et accompagné de plusieurs exemples.
### Sous répertoire Web

Parfois, un site web ne référence pas toutes les pages qu'il met en ligne. 
Il convient d'effectuer une recherche de ces sous répertoires avec l'outil que l'on veut, et la wordlist souhaitée. 

Ici, nous conseillons [ffuf](https://github.com/ffuf/ffuf) qui est plutôt rapide avec une sortie claire. 

```bash
ffuf -c -u http://IP_Cible/FUZZ -w /usr/share/wordlists/seclists/Discovery/Web-Content/big.txt -mc 200, 401
```

>`FUZZ` sera remplacé par chaque élément de la liste de mot
 `-c` permet de colorer l'output
 `-u` pour la cible et `-w` pour la wordlist (Seclist est disponible sur [Github](https://github.com/danielmiessler/SecLists))
 `-mc` permet de filtrer la sortie sur les codes HTTP rettournés

Pour plus d'informations, => Lien_article_ffuf_en_cours
### Virtual Hosts - Sous domaine

Toujours avec `ffuf`, avec le header `HOST` de la requête HTTP : 

Prenons l'exemple d'un site d'intranet. Nous savons que cette requête avec ce header existe :   
```bash
echo "intranet" | ffuf -c -w - -u http://intranet.fsociety.hack:2600 -H "Host: FUZZ.fsociety.hack:2600"
```

{{< image src="images/methodo_boot-to-root1.png" caption="" alt="alter-text" height="" width="" position="center" command="fill" option="q100" class="img-fluid" title="image title" webp="false" >}}

Et prenons un exemple de requête qui ne sont pas valides : 

```bash
ffuf -c -w /usr/share/wordlists/seclists/Discovery/Web-Content/big.txt -u http://intranet.fsociety.hack:2600 -H "Host: FUZZ.fsociety.hack:2600" -mc 200
```

{{< image src="images/methodo_boot-to-root2.png" caption="" alt="alter-text" height="" width="" position="center" command="fill" option="q100" class="img-fluid" title="image title" webp="false" >}}

On peut constater que les valeurs diffèrent de notre exemple valide, notamment la taille de la requête. L'objectif ici est de chercher à exclure les requêtes qui contiennent ces valeurs  afin d'extraire les faux positifs de notre output. 

```bash
ffuf -w /usr/share/wordlists/seclists/Discovery/Web-Content/big.txt -u http://intranet.fsociety.hack:2600 -H "Host: FUZZ.fsociety.hack:2600" -fs 90912
```

> -fs permet de filtrer sur la size, d'autres options sont également possible pour le nombre de mots ou de ligne. 

{{< image src="images/methodo_boot-to-root3.png" caption="" alt="alter-text" height="" width="" position="center" command="fill" option="q100" class="img-fluid" title="image title" webp="false" >}}

On a donc trouvé un nouvel hôte virtuel sur ce même serveur, si l'on ajoute `developer.fsociety.hack` dans notre `/etc/hosts`, il sera accessible depuis un navigateur. 

### Paramètre Web

Si un site charge ses pages via des id comme par exemple via un URL : `http://intranet.fsociety.hack/?page_id=1`

On peut aisément utiliser `ffuf` pour énumérer ses pages, et ne filtrer que celles "existantes" avec les  :


```bash
for i in {1 .. 2600};do echo $i >> dict.txt; done

ffuf -w dict.txt -u http://intranet.fsociety.hack:2600/?page_id=FUZZ -mc 200,301
```

### Technologies utilisées

Même si certaines informations peuvent être accessible lors de l'énumération des ports, c'est parfois intéressant de croiser ces données avec une analyse des technologies d'un site. Pour l'exploitation d'une SSTI par exemple, comprendre le langage de programmation utilisé pour déterminer le langage a utiliser pour notre payload est primordiale. 

Des outils comme `whatweb` peuvent être utilisés : 

```python
whatweb -a 3 http://intranet.fsociety.hack:2600
http://intranet.fsociety.hack:2600 [200 OK] Apache[2.4.59], Country[RESERVED][ZZ], HTML5, HTTPServer[Debian Linux][Apache/2.4.59 (Debian)], IP[172.17.0.2], MetaGenerator[WordPress 6.5.3], Script[importmap,module], Title[Intranet], UncommonHeaders[link], WordPress[6.5.3]
```

Ou encore des extensions de navigateur comme [Wappalyzer](https://www.wappalyzer.com/)
## Exploitation / Escalation priv

## Énumération post escalation

Une seconde phase d'énumération est très souvent nécessaire dès que l'on a obtenu un accès à une nouvelle machine ou un à utilisateur avec des privilèges supplémentaires.  

### Techniques manuelles 

En fonction de la situation, la première commande à utilisée est celle-ci : 
```bash
sudo -l 
```

Qui vous permettra de connaître les droits binaires que votre utilisateur peut exécuter en empruntant les droits sudo, soit root. 

Ensuite, avec la commande `find`, on peut retrouver les fichiers en fonction de leurs types, de leurs privilèges, ou de leur nom. C'est à vous d’apprécier la bonne recherche à effectuer en fonction du contexte.

```bash
find / -{writable/readable/executable} 2>/dev/null
```

```bash
find /var -name "*username*" 2>/dev/null
```

```bash
find / -type f 2>/dev/null
```

Ne pas oublier de chercher dans les fichiers/dossiers cachés de notre utilisateur
```bash
ls -la ~
```

Qui peut contenir : 
```bash
.ssh # Dossier ssh, peut contenir des clefs privées
.bash_history # Historique de commande de l'utilisateur, peut contenir des mots de passe
.kdbx # Coffre fort de mot de passe
.git # 
```

Prêter attention aux services en cours aussi à la recherche d'un mot de passe

```bash
ps -aux 
```

N'oubliez pas non plus de jeter un œil aux tâches planifiées et aux répertoires des systèmes d'initialisation utilisés pour gérer les services et processus au démarrage comme `systemd` et `initd`
```bash
ls -lRa /etc/cron*
ls -la /etc/init.d/
ls -la /etc/systemd/system
```

### Techniques automatiques

Si vous avez un accès internet sur la box et la possibilité d’exécuter un script, il existe des scripts qui effectuent cette reconnaissance automatiquement. 

Sur linux, il s'agit de [LinPEAS - Linux Privilege Escalation Awesome Script](https://github.com/peass-ng/PEASS-ng/tree/master/linPEAS)

Sur Windows, il s'agit de [Windows Privilege Escalation Awesome Script (.exe)](https://github.com/peass-ng/PEASS-ng/blob/master/winPEAS/winPEASexe/README.md)