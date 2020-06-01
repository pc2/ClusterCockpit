#!/bin/bash

jobid="$1"
#get nodes of jobid
nsadir="/scratch/pc2-mitarbeiter/rschade/nsa2/data"

programs=""
if [[ ! -d "$nsadir/jobs/$jobid/" ]];
then
  echo "not_detected"
else

  for h in $(ls "$nsadir/jobs/$jobid/"); do
    while read meta; do
     hash=$(grep -h '^EXEHASH=' $nsadir/nodes/$h/*/$meta | grep -v "^EXEHASH=$" | sed "s/^EXEHASH=//g" | tail -n 1)
     p=$(grep -h "^$hash " /scratch/pc2-mitarbeiter/rschade/nsa2/data/exelist | cut -d' ' -f2 | cut -d'_' -f1)
     echo "$(grep -h '^EXEHASH=' $nsadir/nodes/$h/*/$meta) _${p}_" >&2
     if [[ ! $programs =~ "$p" ]]; then
       programs="$programs $p"
     fi

    done < $nsadir/jobs/$jobid/$h
  done
  if [[ "$programs" == "" ]]; then
    programs="unknown"
  fi 
  if [[ "$programs" == " " ]]; then
    programs="unknown"
  fi 
  echo "$programs"
fi
