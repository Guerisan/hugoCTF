---
title: Volatility 2 ou 3 ? 
meta_title: ""
description: Documentation d'installation et d'utilisation
date: 2024-04-04T05:00:00Z
image: /images/Volatility_logo.png
categories:
  - Outils
author: Tmax
tags:
  - Outils
  - Fiches
  - Forensic
draft: false
---

# Volatility

{{< notice "note" >}}
Attention, l'installation ci-dessous ne prends pas en compte l'usage des Venv. 
{{< /notice >}}

## Installation vol2

Pour Vol2 il faut faire attention de bien utiliser pip2 ainsi que python2 lors de l'exécution des commandes ci-dessous :
https://seanthegeek.net/1172/how-to-install-volatility-2-and-volatility-3-on-debian-ubuntu-or-kali-linux/

Source : https://github.com/volatilityfoundation/volatility/wiki/Installation

Voici la bonne démarche à suivre pour le faire :

To install system-wide for all users, use the `sudo` command in front of the `python2` commands.

(sudo su) 
```sh
sudo apt-get install python2-dev git -y #(build-essential curl yara)
curl https://bootstrap.pypa.io/pip/2.7/get-pip.py --output get-pip.py
python2.7 get-pip.py
nano ~/.bashrc # puis ajouter : "export PATH="$HOME/.local/bin:$PATH" " 
source ~/.bashrc (ou ./zshrc)
pip2 install -U setuptools
pip2 install distorm3==3.4.4 # if failed dw, only used for yara rules
wget https://ftp.dlitz.net/pub/dlitz/crypto/pycrypto/pycrypto-2.6.1.tar.gz
tar -xvzf pycrypto-2.6.1.tar.gz
cd pycrypto-2.6.1
sudo python2.7 setup.py build install
cd ..
sudo chmod +x ./install_vol.shc # Script dispo ci dessous
./install_vol.sh
```

Pour avoir la version / être sur que pip2 soit installé
```
python2.7 -m pip -V
```

 où
 
 install_vol.sh =
```sh
#!/bin/bash
echo "Install volatility"
VOL_EXIST=$(which volatility)

if [ "$VOL_EXIST" == "" ];then
	#pip install distorm3
	python2 -m pip install -U yara pycrypto pillow openpyxl ujson pytz ipython capstone
	sudo python2 -m pip install yara
	sudo ln -s /usr/local/lib/python2.7/dist-packages/usr/lib/libyara.so /usr/lib/libyara.so
	sudo mkdir /opt/volatility
	sudo chmod 755 /opt/volatility -R
	sudo git clone https://github.com/volatilityfoundation/volatility /opt/volatility
	cd /opt/volatility
	sudo python2.7 setup.py install
	sudo mv /usr/local/bin/vol.py /usr/local/bin/volatility
fi
```

IF DONE : 

```sh
┌──(tmax㉿kali)-[~/tools]
└─$ volatility       
Volatility Foundation Volatility Framework 2.6.1
ERROR   : volatility.debug    : You must specify something to do (try -h)

```


SUPRESSION : 
```sh
sudo rm -rf /usr/local/lib/python*.*/dist-packages/volatility
sudo rm `which vol.py` && sudo rm `which volatility`
sudo rm -rf /usr/local/contrib/plugins 
sudo rm -f /usr/local/bin/volatility
```


##  Installation Vol3

avant d'installer pycrypto :
`sudo apt-get install python3-dev`

```sh
sudo apt install -y python3 python3-dev libpython3-dev python3-pip python3-setuptools python3-wheel
```

```sh
python3 -m pip install -U distorm3 yara pycrypto pillow openpyxl ujson pytz ipython capstone 
python3 -m pip install -U git+https://github.com/volatilityfoundation/volatility3.git
```

{{< notice "note" >}}
if issue, replace yara par yara-python 
replace pycrypto par pycryptodome
{{< /notice >}}

add `/home/username/.local/bin` to PATH 


IF DONE : 

```sh
┌──(tmax㉿kali)-[~/tools]
└─$ vol                  
Volatility 3 Framework 2.7.0
usage: volatility [-h] [-c CONFIG] [--parallelism [{processes,threads,off}]]
                  [-e EXTEND] [-p PLUGIN_DIRS] [-s SYMBOL_DIRS] [-v] [-l LOG]
                  [-o OUTPUT_DIR] [-q] [-r RENDERER] [-f FILE]
                  [--write-config] [--save-config SAVE_CONFIG] [--clear-cache]
                  [--cache-path CACHE_PATH] [--offline] [--filters FILTERS]
                  [--single-location SINGLE_LOCATION]
                  [--stackers [STACKERS ...]]
                  [--single-swap-locations [SINGLE_SWAP_LOCATIONS ...]]
                  plugin ...
volatility: error: Please select a plugin to run

```

# CMDLIST

### What type of dump am I going to analyze ?
```sh
 volatility -f MyDump.dmp imageinfo
```

### Which process are running
```sh
volatility -f MyDump.dmp --profile=MyProfile pslist
volatility -f MyDump.dmp --profile=MyProfile pstree
volatility -f MyDump.dmp --profile=MyProfile psxview
```

### List open TCP/UDP connections
```sh
volatility -f MyDump.dmp --profile=MyProfile connscan
volatility -f MyDump.dmp --profile=Win10x64_19041  sockets
volatility -f MyDump.dmp --profile=MyProfile netscan
```

### What commands were lastly run on the computer
```sh
volatility -f MyDump.dmp --profile=MyProfile cmdline
volatility -f MyDump.dmp --profile=MyProfile consoles
volatility -f MyDump.dmp --profile=MyProfile cmdscan
```

### Dump processes exe and memory 
```sh
volatility -f MyDump.dmp --profile=MyProfile procdump -p MyPid --dump-dir .
volatility -f MyDump.dmp --profile=MyProfile memdump -p MyPid --dump-dir .
```

### Hive and Registry key values
```sh
volatility -f MyDump.dmp --profile=MyProfile hivelist
volatility -f MyDump.dmp --profile=MyProfile printkey -K "MyPath"
```

### Example 
```sh
python2.7 vol.py -f memdump.mem --profile=Win10x64_19041 hivelist
```

### Récupérer le password d’un user

Cette épreuve consistait à **récupérer le password** de l’utilisateur **ctfuser**. Il faut savoir que sur Windows les password locaux sont stockés dans `%SystemRoot%\system32\Config\SAM.` **SAM** est ~~celui qui ne boit pas~~ l’abréviation de [Security Account Manager](https://fr.wikipedia.org/wiki/Security_Account_Manager). Les fichiers sont stocké sous cette forme:

`Username:RID:LMHash:NTLM_HASH:::`

Le **RID** (Relatif ID) est la dernière partie du **SID** ([Security Identifier](https://fr.wikipedia.org/wiki/Security_Identifier)). Chaque entité effectuant des actions sur la machine se voit attribué un [SID](https://fr.wikipedia.org/wiki/Security_Identifier). Le password que l’on cherche est celui hashé en **NTLM_HASH**. La commande pour récupérer les hash de password sous volatility:

```sh
volatility.exe -f le_fichier --profie=Win7SP1x64 hashdump -y SYSTEM_OFFSET -s SAM_OFFSET
```

Il est donc nécessaire de récupérer l’adresse virtuelle de la ruche  **`KEY_LOCAL_MACHINE\SAM`**  et `KEY_LOCAL_MACHINE\System`. Pour cela comme précédement on utilise la commande hivelist

{{< image src="images/methode_vol2_hivelist.png" caption="" alt="alter-text" height="" width="" position="center" command="fill" option="q100" class="img-fluid" title="image title" webp="false" >}}

{{< image src="images/methode_vol2_hashdump.png" caption="" alt="alter-text" height="" width="" position="center" command="fill" option="q100" class="img-fluid" title="image title" webp="false" >}}


Le password (hashé) de l’administrateur est **31d6cfe0d16ae931b73c59d7e0c089c0** tout comme celui du guess, **cela correspond à pas de password** ;). Si vous regarder bien chaque LMHASH est le même alors que deux NTLM_HASH sont différents. Cela s’explique par le fait que l’algorithme LMHASH est devenu bidon, **sa sécurité jugée trop basse**. Ainsi par défaut le hash sera **aad3b435b51404eeaad3b435b51404ee** qui correspond à pas de password.
  
Sinon le hash qui nous intéresse est celui ci : **320a78179516c385e35a93ffa0b1c4ac.** Pour obtenir le password il existe plusieurs solutions comme le brute force avec **John The Ripper** par exemple ou alors on consulte des base de données de crack en ligne comme [crackstation](https://crackstation.net/).




### Made custom profile vol3
[Build a Custom Linux Profile for Volatility3 | by Alireza Taghikhani | Aug, 2023 | Medium](https://medium.com/@alirezataghikhani1998/build-a-custom-linux-profile-for-volatility3-640afdaf161b)

### Liens utiles
-   ***help by*** : [0xswitch | Usage de base de volatility](https://0xswitch.fr/posts/usage-de-base-de-volatility) 
-   [https://github.com/volatilityfoundation/volatility/wiki/Command-Reference](https://github.com/volatilityfoundation/volatility/wiki/Command-Reference)
-   [https://digital-forensics.sans.org/media/memory-forensics-cheat-sheet.pdf](https://digital-forensics.sans.org/media/memory-forensics-cheat-sheet.pdf)
-   [https://downloads.volatilityfoundation.org/releases/2.4/CheatSheet_v2.4.pdf](https://downloads.volatilityfoundation.org/releases/2.4/CheatSheet_v2.4.pdf)    
- [Volatility - CheatSheet - HackTricks](https://book.hacktricks.xyz/generic-methodologies-and-resources/basic-forensic-methodology/memory-dump-analysis/volatility-cheatsheet)




# Make dump

- Using FTK_imager :
	- .mem generated 
	- moins efficace avec hashdump et filescan (vol2)
	- [Exterro](https://www.exterro.com/ftk-imager)
- Using DumpIt :
	- .raw generated
	- Efficace
	- [GitHub](https://github.com/thimbleweed/All-In-USB/blob/master/utilities/DumpIt/DumpIt.exe) [sourceforge.net](https://sourceforge.net/projects/jumpbag/files/latest/download)

