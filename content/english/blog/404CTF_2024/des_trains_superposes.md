---
title: 404 CTF - Des trains superposes
meta_title: ""
description: Write-up quantique introduction qubits
date: 2024-06-23T05:00:00Z
image: /images/404CTF_logo.png
categories:
  - 404CTF
  - moyen
author: Bafrac
tags:
  - programmation
  - quantique
draft: false
isSecret: false
---

{{< image src="images/des_trains_superposes/trains-1.png" caption="Le probable commencement." alt="rails de train" height="" width="" position="center" command="fill" option="q100" class="img-fluid" title="image title" webp="false" >}}


# Introduction

On veut des points de CTF donc on veut savoir comment les anciens challenges marchent. Ici on veut avoir les challenges les plus durs avec le moins de points comme récompense.
Les challenges et la programmation quantique repose sur les qubits, des bits quantiques qui peuvent être 0, 1, les deux en même temps... Cela permet à certains programmes de faire des calculs sur des registres quantiques de plusieurs qubits plus rapidement que des bits lorsque l'on veut tester toutes les possibilités.

Il y aura dans ce write up plusieurs formules écrites en LaTeX, pour les voir copiez-collez la formule dans un site tel que https://www.quicklatex.com/ 

## Apprentissage des bases

Pour faire le challenge il faut suivre le Jupiterbook, ça se fait  sans soucis, les nouveaux éléments sont affiché afin d'être visuellement plus compréhensible.

L’algorithmie quantique manipule des qubits, on les manipules avec des matrices. Ces matrices sont des portes "logiques", il y a un grand nombre de portes (et donc de matrices) spécifique à la manipulation de qubits, le début du Jupiterbook est la création de ces portes comme la porte qui est l'équivalent de la porte NOT, même si c'est plus compliqué. 

Ensuite on nous montre comment on peut analyser une porte avec une entrée précise, puis toutes les entrées.
```python
pcvl.pdisplay(analyser)
pcvl.pdisplay(x_gate.definition())
```


Il est ensuite montré que le mappage permet de voir plus simplement les différents état lors de l'analyse des différentes possibilités.
```python
p = pcvl.Processor("Naive", super_circuit)
analyser = pcvl.algorithm.Analyzer(
	p,
	input_states=list(qubits.values()),
	output_states=list(qubits.values()),
	mapping=qubits_
)
pcvl.pdisplay(analyser)
  
analyser = pcvl.algorithm.Analyzer(
	p,
	input_states=list(qubits.values()),
	output_states=list(qubits.values())
)
pcvl.pdisplay(analyser)
  
pcvl.pdisplay(super_circuit)
```


Notion importante à retenir:
***latex***
```python 
|a\rangle = X|\b\rangle
```

Signifie que on passe d'un état b avec une matrice X) donne état a. On fait la multiplication des matrices.
Voici l'exemple d'une porte NOT en matrice multipliant un bit pour l'inverser:***latex***


```python
|\phi\rangle = X|1\rangle = \begin{pmatrix} 0 & 1 \\ 1 & 0 \end{pmatrix} \begin{pmatrix} 0 \\ 1 \end{pmatrix} = \begin{pmatrix} 1 \\ 0 \end{pmatrix} = |0\rangle
```




## Porte d'Hadamar
Avec un analyser on voit que la porte Hadamard montre que si 0 est donné en entré, il a une chance sur 2 d'être 1 ou 0.

Si on regarde le backend on voit 0,707 pour les deux:
```python
backend = pcvl.BackendFactory.get_backend("Naive")
backend.set_circuit(hadamard_gate)
backend.set_input_state(qubits["0"])
ampl0, ampl1 = backend.prob_amplitude(qubits["0"]), backend.prob_amplitude(qubits["1"])
print(f"|phi> = {ampl0} |0> + {ampl1} |1>")
|phi> = (0.7071067811865476+0j) |0> + (0.7071067811865475+0j) |1>
```

Amplitude de probabilité et la probabilité ne sont pas la même chose.
Les amplitudes de probabilité sont des nombres complexes qui capturent à la fois l'amplitude et la phase de la probabilité d'un état quantique. Pour obtenir la probabilité de mesure d'un état, vous devez prendre le carré de la valeur absolue de l'amplitude de probabilité pour cet état.
***latex***
```python
\frac{1}{\sqrt{2}} = 0,70707
|0,70707* 0,70707| = 0,5
```

les déphaseurs sont des outils dans le domaine de l'informatique quantique, offrant la possibilité de manipuler sélectivement la phase des états quantiques pour diverses applications, notamment dans la correction des erreurs, la conception de circuits quantiques et la manipulation des interférences quantiques.

Ensuite, vous avez construit un circuit quantique avec le déphaseur en utilisant `pcvl.Circuit(2) // (0, phase_shifter)`. Dans cette ligne de code, vous avez créé un circuit quantique avec 2 modes spatiaux (ou qubits). Le déphaseur est ajouté au circuit en tant que porte quantique sur le mode spatial (ou qubit) numéro 0. Cela signifie que le déphaseur agira uniquement sur le qubit connecté à ce mode spatial.

Les phases en très simple (en vrai j'ai pas compris) sont des matrices qui impacte seulement des qubits choisi.


## Beam splitter
Un Beam splitter est une matrice qui est la généralisation de la porte d'Hadamard, on l'utilise avec un paramètre souvent une lettre grec.
Lorsque vous créez un Beam splitter avec une variable symbolique \(\alpha\), la matrice à laquelle ça correspond est :

```python
U = \begin{pmatrix}
\cos\left(\frac{\alpha}{2}\right) & i\sin\left(\frac{\alpha}{2}\right) \\
i\sin\left(\frac{\alpha}{2}\right) & \cos\left(\frac{\alpha}{2}\right)
\end{pmatrix}
```

En assignant (alpha = pi/2), vous obtenez :***latex***

```python
\cos\left(\frac{\pi}{4}\right) = \frac{\sqrt{2}}{2} \quad \text{et} \quad \sin\left(\frac{\pi}{4}\right) = \frac{\sqrt{2}}{2}
```
La matrice unitaire devient alors : ***latex***

```python 
U = \begin{pmatrix}
\frac{\sqrt{2}}{2} & i\frac{\sqrt{2}}{2} \\
i\frac{\sqrt{2}}{2} & \frac{\sqrt{2}}{2}
\end{pmatrix}
```


### Changement de la Valeur de alpha

En assignant alpha = π, vous obtenez : ***latex***
```python
U = \begin{pmatrix}
  \cos\left(\frac{\alpha}{2}\right) & i\sin\left(\frac{\alpha}{2}\right) \\
  i\sin\left(\frac{\alpha}{2}\right) & \cos\left(\frac{\alpha}{2}\right)
  \end{pmatrix}

\cos\left(\frac{\pi}{2}\right) = 0 \quad \text{et} \quad \sin\left(\frac{\pi}{2}\right) = 1
```

```python
U = \begin{pmatrix}
0 & i \\
i & 0
\end{pmatrix}
```

# Etape 1
A vous de jouer, il faut assigner à alpha une valeur pour que les chances que 0 en entrée devienne 0 ou 1 10% et 90% de chance respectivement.
L'équation à résoudre est:***latex***
```python
cos²(\frac{\alpha}{2})=\frac{1}{10}
```

Réponse:
```python
2 * np.arccos(np.sqrt(1/10))
```


# Etape 2
Objectif:
 |φ> = (0.87+0j) |0> + (0.43-0.25j) |1>
On a deux éléments sur notre circuit un Beam Splitter  et un Phase shifter, chacun avec un paramètre, il est à noté que:
```python
0,87 = \frac{\sqrt{3}}{2}
0,43 = \frac{\sqrt{3}}{4}
```

Pour trouver les valeurs de beta et gamma (sans tester au hasard comme moi au début ;) ) Il faut combiner les matrices de Beam splitter avec celle de phase shifter:
### Beam Splitter (BS)
La matrice du beam splitter avec un angle beta comme argument est :***latex***

```python
BS\left(\beta\right) = \begin{pmatrix}
\cos\left(\frac{\beta}{2}\right) & i\sin\left(\frac{\beta}{2}\right) \\
i\sin\left(\frac{\beta}{2}\right) & \cos\left(\frac{\beta}{2}\right)
\end{pmatrix}
```


### Phase Shifter (PS)
La matrice du phase shifter avec une phase γ est :***latex***
```python
PS(\gamma) = \begin{pmatrix}
1 & 0 \\
0 & e^{i\gamma}
\end{pmatrix}
```

### Combinaison BS et PS
La matrice représentant la combinaison d'un BS avec un angle beta suivi d'un PS avec une phase gamma est :

```python
\begin{pmatrix}
\cos\left(\frac{\beta}{2}\right) & i\sin\left(\frac{\beta}{2}\right) \\
i e^{i\gamma} \sin\left(\frac{\beta}{2}\right) & e^{i\gamma} \cos\left(\frac{\beta}{2}\right)
\end{pmatrix}
```


### Application de l'état initial 
Lorsqu'on applique cette matrice à l'état initial 
```python
|0\rangle = \begin{pmatrix}1 \\ 0\end{pmatrix}
```
nous obtenons :

```python
\begin{pmatrix}
\cos\left(\frac{\beta}{2}\right) & i\sin\left(\frac{\beta}{2}\right) \\
i e^{i\gamma} \sin\left(\frac{\beta}{2}\right) & e^{i\gamma} \cos\left(\frac{\beta}{2}\right)
\end{pmatrix}
\begin{pmatrix}
1 \\
0
\end{pmatrix}
= 
\begin{pmatrix}
\cos\left(\frac{\beta}{2}\right) \\
i e^{i\gamma} \sin\left(\frac{\beta}{2}\right)
\end{pmatrix}
```


### Système d'équations
Les équations pour les amplitudes finales sont les suivantes :

```python
\begin{cases}
\cos\left(\frac{\beta}{2}\right) = \frac{\sqrt{3}}{2} \\
i e^{i\gamma} \sin\left(\frac{\beta}{2}\right) = \frac{\sqrt{3}}{4} - \frac{1}{4}i
\end{cases}
```

## Résolution de Beta:
```python
\cos{\frac{\beta}{2}} = \frac{\sqrt{3}}{2}
```

Constante pratique du cercle trigonométrique si on s'en souvient:
```python
\frac{\sqrt{3}}{2} = \cos\frac{\pi}{6}
```
On a donc:
```python
\cos{\frac{\beta}{2}} = \frac{\sqrt{3}}{2} \implies \cos{\frac{\beta}{2}} = \cos{\frac{\pi}{6}}
```
```python
\cos{\frac{\beta}{2}} = \cos{\frac{\pi}{6}}  \implies \beta = \pm\frac{\pi}{3}
```
## Résolution de Gamma
On a:
```python
\beta = \pm\frac{\pi}{3}
```
```python
i e^{i\gamma} \sin\left(\frac{\beta}{2}\right) = \frac{\sqrt{3}}{4} - \frac{1}{4}i
```
En utilisant sin(6π​)=1/2​

```python
i e^{i\gamma} \frac{1}{2} = \frac{\sqrt{3}}{4} - \frac{1}{4}i
```
En multipliant par deux de chaque côtés:

```python
i e^{i\gamma}  = \frac{\sqrt{3}}{2} - \frac{1}{2}i
```
en multipliant des deux côtés par -i:
```python
e^{i\gamma}  = -\frac{1}{2}- i\frac{\sqrt{3}}{2}
```
En identifiant les parties réelles et imaginaires :
```python
\cos(\gamma) + i\sin(\gamma)  = -\frac{1}{2}- i\frac{\sqrt{3}}{2}
```

Comme les valeurs de cos⁡(γ)et sin⁡(γ) correspondent à un angle dans le troisième quadrant.

```python
\gamma = -\frac{\sqrt{3}}{2}
```

On peut refaire l'équation avec l'autre valeur de beta:
```python
\beta = -\frac{\pi}{3} \implies  e^{i\gamma} = \frac{\frac{\sqrt{3}}{4} - \frac{1}{4}i}{\frac{i}{2}} = \frac{\sqrt{3}}{2} + \frac{1}{2} \implies \gamma = \frac{\pi}{3}
```

## Solution

```python
\begin{cases}
\beta = \frac{\pi}{3} \\
\gamma = -\frac{2\pi}{3}
\end{cases}
```

```python
beta = np.pi / 3
gamma = - 2* np.pi / 3
```



# Etape 3

## Sphère de Bloch
La sphère de Bloch est tout ce qui a été vu durant le challenge vu de manière visuelle et condensée. Chacun des axes représente un paramètre de comportement d'un qubit, si il a plus de chance d'être 1, 0, les deux, la probabilité qu'il soit les deux...

{{< image src="images/des_trains_superposes/Bloch_1.png" caption="Sphère de Bloch."  height="" width="" position="center" command="fill" option="q100" class="img-fluid" title="image title" webp="false" >}}

La dernière étape est de passer d'un certain qubits à un autre en passant par un intermédiaire pour rendre les choses plus simple.
```python
start_state = np.array([np.sqrt(2+np.sqrt(2))/2, np.sqrt(2-np.sqrt(2))/2 * (np.sqrt(2)/2 - 1j * np.sqrt(2)/2)])
plot_bloch_multivector(start_state)
  
step_state = np.array([np.sqrt(2)/2, -np.sqrt(2)/2])
plot_bloch_multivector(step_state)
  
finish_state = np.array([np.sqrt(2-np.sqrt(2))/2, np.sqrt(2+np.sqrt(2))/2 * (np.sqrt(2)/2 + 1j * np.sqrt(2)/2)])
plot_bloch_multivector(finish_state)
  
 
start = y_rot(np.pi/4) // z_rot(-np.pi/4) # Pour se placer sur le départ
  
delta = ...
epsilon = ...
zeta = ...
eta = ...
  
# Une autre façon d'enchaîner les portes
final_step = (start
.add(0, z_rot(delta))
.add(0, y_rot(epsilon)) # Arrivé à l'étape Hadamard
.add(0, y_rot(zeta))
.add(0, z_rot(eta)) # Fin du parcours !
)
#plot_bloch(final_step)
```

{{< image src="images/des_trains_superposes/Bloch_2.png" caption="Sphère de Bloch."  height="" width="" position="center" command="fill" option="q100" class="img-fluid" title="image title" webp="false" >}}

C'est l'étape la plus graphique et intuitive, tenter des valeurs (du cercle trigonométrique) et vous finirez par l'avoir, vous pouvez voir à quel point vous êtes loin ou proche.

Ma solution? 4 fois la même valeur
```python
delta = np.pi/4
epsilon = np.pi/4
zeta = np.pi/4
eta = np.pi/4
```

Finissez le JupyterBook pour envoyer les valeurs et c'est bon! Vous avez finis un long challenge remplis de matrices, de qubits, de programmation et équation pour le nombre minimal de point du 404CTF!
Hesitez pas à aller voir le github de la personne qui a fait le challenge (et sa propre solution):
https://github.com/Sckathach/404CTF-2024-Algorithmique-quantique/tree/main


