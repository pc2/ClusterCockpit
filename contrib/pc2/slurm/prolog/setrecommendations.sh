#!/bin/bash
if [ "$SPANK_RECOMMENDATIONS" == "on" ];
then
  rm -f /tmp/disablecollectors
  cd /cm/shared/scripts/jobmonitoring/bnd/
  . /etc/profile.d/modules.sh
  module use /cm/shared/apps/pc2/EB-SW/modules/all
  module load lang/Python/3.7.0-foss-2018b
  module load slurm
  export PATH=$PATH:/usr/bin/
  env > /tmp/env
  python3 api.py start ${SLURM_JOBID} ${SLURM_JOB_USER} `date +%s` `hostname`
  python3 api.py setOutputRecommendations ${SLURM_JOBID} slurm 
fi
