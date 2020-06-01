#!/bin/bash
module load slurm
module use /cm/shared/apps/pc2/EB-SW/modules/all
module load lang/Python/3.7.0-foss-2018b

while true; do
  tmp=`mktemp`
  tmp1=`mktemp`
  tmp2=`mktemp`

  #get all running jobs in cluster cockpit
  python3 api.py getjobs > $tmp1
  #get all running jobs without updates in cluster cockpit
  python3 api.py getjobswithoutupdate > $tmp2
  #get all jobs currently running in slurm
  squeue -o "%t|%i|%a|%u|%S|%N" | grep "^R|" > $tmp


  l=`cat $tmp1 | wc -l`
  echo "`date +%s` communicate all jobs that are not running anymore to clustercockpitidb $l"
  for i in `seq 1 $l`;
  do
    line=`head -n $i $tmp1 | tail -n 1`
    jobid=$line
    m=`grep "|$line|" $tmp | wc -l `
    if [[ "$m" == "0" ]];
    then
      stoptt=`sacct -j $line -X -o end -n -p`
      stopl=`echo "$stoptt" | grep "|" | wc -l`
      unknown=`echo "$stoptt" | grep "Unknown" | wc -l`
      stoptime=""
      if [[ "$unknown" == "0" ]] && [[ "$stopl" != "0" ]]; then
        stoptt2=`echo "$stoptt" | sed "s/|//g"`
        stoptime=`date --date="$stoptt2" +"%s"`
      else
        stoptime=`date +%s`
      fi
        echo "stoptt=$stoptt $stopl $unknown $stoptime"
        python3 api.py stop $jobid $stoptime

        #running program
        exes=$(bash get_program.sh $jobid)
        python3 api.py removetagsoftype $jobid program
        for exe in $exes; do
          python3 api.py addtag $jobid $exe program
        done
        
        #recommendations
        python3 api.py checkproblems $jobid
        recommendmode=`python3 api.py getOutputRecommendations $jobid | grep "OutputRecommendations" | awk 'BEGIN { FS = "=" } ; { print $2 }'`
        if [[ "$recommendmode" == *"slurm"* ]];
        then
          #get path of output file
          wdir=`sacct -j $jobid -X -o WorkDir%1000 -n | sed -e 's/^[[:space:]]*//' | head -n 1 |  sed -e 's/[[:space:]]*$//'`
          echo "writing recommendations to \"$wdir/slurm-${jobid}.recommendations\""
          user=`sacct -j $jobid -X -o User%1000 -n | sed -e 's/^[[:space:]]*//' | sed -e 's/*[[:space:]]*$//' | head -n 1`
          tmpr=`mktemp`
          echo "<div class=\"row\">" > $tmpr
          echo "Recommendations to improve this job:" >> $tmpr
          echo "<table class=\"table table-sm table-striped\">" >> $tmpr
          echo "<tbody>" >> $tmpr
          python3 api.py getproblems $jobid >> $tmpr
          echo "</tbody>" >> $tmpr
          echo "</table>" >> $tmpr
          echo "</div>" >> $tmpr
          cat $tmpr
          #convert to txt
          tmpt=`mktemp`
          /cm/shared/scripts/jobmonitoring/bnd/pandoc-2.9.2.1/bin/pandoc -f html -t markdown -s $tmpr -o $tmpt
          cat $tmpt
          cat $tmpt | su $user -c "cat > \"$wdir/slurm-${jobid}.recommendations\""
          rm $tmpr
          rm $tmpt
       fi
       python3 api.py setlastupdate $jobid `date +%s`
    fi
  done

  l=`cat $tmp | wc -l`
  echo "`date +%s` communicate all new jobs $l"
  for i in `seq 1 $l`;
  do
#    echo "new $i of $l"
    line=`head -n $i $tmp | tail -n 1`
    jobid=`echo "$line" | awk 'BEGIN { FS = "|" } ; { print $2 }'`
    account=`echo "$line" | awk 'BEGIN { FS = "|" } ; { print $3 }'`
    user=`echo "$line" | awk 'BEGIN { FS = "|" } ; { print $4 }'`
    startt=`echo "$line" | awk 'BEGIN { FS = "|" } ; { print $5 }'`
    unknown=`echo "$startt" | grep "Unknown" | wc -l`
#    echo "$jobid $startt"
    if [ "$unknown" == "0" ]; then
	    m=`grep "^$jobid$" $tmp1 | wc -l `
           n=`grep "^$jobid$" $tmp2 | wc -l`

 	    if [[ "$m" == "0" ]] || [[ "$n" == "1"  ]];
	    then
	      nod=`echo "$line" | awk 'BEGIN { FS = "|" } ; { print $6 }'`
  	      nodes=`scontrol show nodes=$nod | grep NodeName | awk 'BEGIN { FS = "=" } ; { print $2 }' | awk 'BEGIN { FS = " " } ; { print $1 }' | tr "\n" "," | sed "s/,$//g"`
 
	      starttime=`date --date="$startt" +"%s"`
#	      echo "sending job start $jobid $unknown"
	      python3 api.py start  $jobid $user $starttime $nodes
             python3 api.py setnodes $jobid $nodes
             python3 api.py addtag $jobid "not_detected" program
             #python3 api.py setOutputRecommendations $jobid "no"
             python3 api.py setlastupdate $jobid `date +%s`
	      #echo "$jobid " >> cache
	    fi
    fi
  done
 
 if [[ "1" == "1" ]];then
  echo "`date +%s ` communicate for all running jobs which program was used"
  l=`cat $tmp | wc -l`
  for i in `seq 1 $l`;
  do
    echo "$i of $l"
    line=`head -n $i $tmp | tail -n 1`
    jobid=`echo "$line" | awk 'BEGIN { FS = "|" } ; { print $2 }'`
    account=`echo "$line" | awk 'BEGIN { FS = "|" } ; { print $3 }'`
    user=`echo "$line" | awk 'BEGIN { FS = "|" } ; { print $4 }'`
    startt=`echo "$line" | awk 'BEGIN { FS = "|" } ; { print $5 }'`
    unknown=`echo "$startt" | grep "Unknown" | wc -l`
#    echo "$jobid $startt"
    if [ "$unknown" == "0" ]; then
      pr=`python3 api.py gettags $jobid program`
      programknown=`echo "$pr" | egrep "not_detected|unknown" | wc -l`
      echo "$jobid $pr $programknown"
      
#      lastupdate=`python3 api.py getlastupdate $jobid | grep "lastupdate" | awk 'BEGIN { FS = "=" } ; { print $2 }'`
#      tt=`date +%s`
#      echo "$jobid lastupdate=$lastupdate, now=$tt"
#      c=`echo "$tt>$lastupdate+3600" | bc`
      if [[ "$programknown" != "0" ]] || [[ "$pr" == "" ]];
      then
        #running program
        exes=$(bash get_program.sh $jobid)
      	echo "exes=$exes"
        if  [[ "$exes" != "not_detected" ]];then
          python3 api.py removetagsoftype $jobid program
          for exe in $exes; do
            python3 api.py addtag $jobid $exe program
          done
          python3 api.py setlastupdate $jobid `date +%s`
        fi

      fi
    fi
  done
fi
  
  rm $tmp
  rm $tmp1
  rm $tmp2
  sleep 5
done
