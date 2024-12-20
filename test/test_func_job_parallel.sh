### matlab_test_job.sh START ###
#!/bin/bash
#$ -cwd
# error = Merged with joblog
#$ -o test/cluster-output/job-$JOB_ID/joblog_$JOB_ID_$TASK_ID.txt
#$ -j y
## Edit the line below as needed:
#$ -l h_rt=1:00:00,h_data=1G
## Modify the parallel environment
## and the number of cores as needed:
#$ -pe shared 1
# Email address to notify
#$ -M $USER@mail
# Notify when
# #$ -m bea
#$ -t 1:3:1  # 1-indexed here


# echo job info on joblog:
echo "Job $JOB_ID started on:   " `hostname -s`
echo "Job $JOB_ID started on:   " `date `
echo " "

# load the job environment:
. /u/local/Modules/default/init/modules.sh
# To see which versions of matlab are available use: module av matlab
module load matlab/R2020b
echo "loaded matlab"

total_tasks=$(( ($SGE_TASK_LAST - $SGE_TASK_FIRST) / $SGE_TASK_STEPSIZE + 1 ))

echo "Start Matlab"
echo "task id: $SGE_TASK_ID, total tasks: $total_tasks"
cd /u/home/x/xinniu/nwbPipeline/test/
matlab  -nosplash -nodisplay -singleCompThread -r "test_func($SGE_TASK_ID, $total_tasks); exit"

# echo job info on joblog:
echo "Job $JOB_ID ended on:   " `hostname -s`
echo "Job $JOB_ID ended on:   " `date `
echo " "
### extract_clusterless_parallel.job STOP ###
# this site shows how to do array jobs: https://info.hpc.sussex.ac.uk/hpc-guide/how-to/array.html
# (better than the Hoffman site https://www.hoffman2.idre.ucla.edu/Using-H2/Computing/Computing.html#how-to-build-a-submission-script)


 