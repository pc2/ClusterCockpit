#!/bin/bash
#sleep 10000000



source /etc/profile.d/modules.sh
module load DefaultModules

while true;
do
        if [[ -d "/scratch/pc2-mitarbeiter/rschade/nsa2" ]];
        then
          cd /scratch/pc2-mitarbeiter/rschade/nsa2
	  bash onnode.sh config 2>&1 >> debuglog/${HOSTNAME}.log 
          source config
	  sleep $PROBEINTERVAL
        else
          sleep 10
        fi
done
