#!/bin/bash
module load slurm
module use /cm/shared/apps/pc2/EB-SW/modules/all
module load lang/Python/3.7.0-foss-2018b

tmp1=`mktemp`
     
#get all running jobs in cluster cockpit
python3 api.py getstoppedjobs > $tmp1

#communicate all jobs that are not running anymore to clustercockpit
l=`cat $tmp1 | wc -l`
echo "$l jobs to update"
for i in `seq 1 $l`;
do
    echo "$i of $l"
    line=`head -n $i $tmp1 | tail -n 1`
    jobid=$line
    stoptt=`sacct -j $line -X -o end -n`
    unknown=`echo "$stoptt" | grep "Unknown" | wc -l`
    if [ "$unknown" == "0" ]; then
      stoptime=`date --date="$stoptt" +"%s"`
      lastupdate=`python3 api.py getlastupdate $jobid | grep "lastupdate" | awk 'BEGIN { FS = "=" } ; { print $2 }' | sed "s/ //g"`
      echo "$jobid lastupdate=$lastupdate"
      if [[ "$lastupdate" == "0" ]]; then
        exes=""
        c=`ls /scratch/pc2-mitarbeiter/rschade/nsa/jobs/$jobid/*/*_meta | wc -l`
        if [[ "$c" == "0" ]];
        then
            python3 api.py removetagsoftype $jobid program
            python3 api.py addtag $jobid "not_detected" program
        else
          for h in `grep EXEHASH /scratch/pc2-mitarbeiter/rschade/nsa/jobs/$jobid/*/*_meta | awk 'BEGIN { FS = "EXEHASH=" } ; { print $2 }' | uniq | tr "\n" " "`;
          do
            exe=`grep "$h" /scratch/pc2-mitarbeiter/rschade/nsa/exelist | awk 'BEGIN { FS = " " } ; { print $2 }' | awk 'BEGIN { FS = "_" } ; { print $1 }' `
            if [[ "$exe" != "" ]];
            then
              if [[ ! $exes == *"$exe"* ]]; then
                exes="$exes $exe"
              fi
            fi
          done

          if [[ "$exes" != "" ]];
          then
            for exe in $exes;
            do
              python3 api.py removetagsoftype $jobid program
              python3 api.py addtag $jobid $exe program
            done
          else
            python3 api.py removetagsoftype $jobid program
            python3 api.py addtag $jobid "unknown" program
          fi
        fi
        #recommendations
        python3 api.py checkproblems $jobid
      
        python3 api.py setlastupdate $jobid `date +%s`
      fi
    fi
done
rm $tmp1
