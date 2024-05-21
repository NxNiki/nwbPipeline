###  submit matlab batch jobs to SGE ###
#!/bin/bash
#$ -cwd
# error = Merged with joblog
#$ -o /u/home/x/xinniu/cluster-log-spikeSort/job572-$JOB_ID/joblog_$JOB_ID_$TASK_ID.txt
#$ -j y
## Edit the line below as needed. The data limit applies for each job individually,
## so no need to change it if you submit more array jobs.
#$ -l h_rt=24:00:00,h_data=500G
## Modify the parallel environment
## and the number of cores as needed:
#$ -pe shared 1
# Email address to notify
#$ -M $USER@mail
# Notify when
# #$ -m bea
#$ -t 1:10:1  # 1-indexed here


# echo job info on joblog:
echo "Job $JOB_ID started on:   " `hostname -s`
echo "Job $JOB_ID started on:   " `date `
echo " "

# load the job environment:
. /u/local/Modules/default/init/modules.sh
# To see which versions of matlab are available use: module av matlab
module load matlab/R2023b
echo "loaded matlab"

total_tasks=$(( ($SGE_TASK_LAST - $SGE_TASK_FIRST) / $SGE_TASK_STEPSIZE + 1 ))

echo "Start Matlab"
echo "run spike sorting, task id: $SGE_TASK_ID, total tasks: $total_tasks"
cd /u/home/x/xinniu/nwbPipeline/batch/
matlab  -nosplash -nodisplay -singleCompThread -r "runbatch_spikeSorting($SGE_TASK_ID, $total_tasks), exit"

rm /u/home/x/xinniu/nwbPipeline/batch/data_wc*.run
rm /u/home/x/xinniu/nwbPipeline/batch/tmp_data_wc*

# echo job info on joblog:
echo "Job $JOB_ID ended on:   " `hostname -s`
echo "Job $JOB_ID ended on:   " `date `
echo " "

### extract_clusterless_parallel.job STOP ###
# this site shows how to do array jobs: https://info.hpc.sussex.ac.uk/hpc-guide/how-to/array.html
# (better than the Hoffman site https://www.hoffman2.idre.ucla.edu/Using-H2/Computing/Computing.html#how-to-build-a-submission-script)


 