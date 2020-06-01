#!/bin/bash
#sleep 10000000

cd /cm/shared/scripts/jobmonitoring

source /etc/profile.d/modules.sh
module use /cm/shared/apps/pc2/CHEM_PHYS_SW/modules                                      
#module use /opt/cray/pe/craype/default/modulefiles
#module use /cm/shared/apps/pc2/EB-SW/modules/all
#module use /cm/shared/apps/pc2/pc2admin/modules
#module use /opt/cray/modulefiles

module load DefaultModules
module load tools/likwid_4.3.4
#module load shared
#module load pc2fs   
#module load slurm/17.11.8   
#module load craype-x86-skylake   
#module load craype-network-opa
#ulimit -s unlimited
#ulimit -l unlimited
#ulimit -n 65536
#ulimit -a 
#module list 
#env

#which likwid-perfctr
#/cm/shared/apps/pc2/CHEM_PHYS_SW/tools/likwid_4.3.4/prefix/bin/likwid-perfctr -i
#/cm/shared/apps/pc2/CHEM_PHYS_SW/tools/likwid_4.3.4/prefix/bin/likwid-perfctr --verbose 3 -g MEM_DP -c 0 -S 1s
#which likwid-lua
#grep -i cpu  /proc/self/status

while true;
do
	echo 0 > /proc/sys/kernel/perf_event_paranoid
	lustre=`ls /proc/fs/lustre/lmv/*/md_stats`
#	lustre=`ls /proc/fs/lustre/llite/*/stats`
	#nice -n 11  numactl --membind=0 --cpubind=0 perl hostmetrics.pl -lustre $lustre -loop -sampletime 10
	#nice -n 19  numactl --membind=0 --cpubind=0 perl hostmetrics.pl -lustre $lustre -loop -sampletime 10
	#numactl --membind=1 --cpubind=1 perl hostmetrics.pl -lustre $lustre -loop -sampletime 10
	source .env
	perl hostmetrics.pl -lustre $lustre -loop -sampletime 10
	sleep 1
done
