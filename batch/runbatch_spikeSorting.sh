###  submit matlab batch jobs to SGE ###
#!/bin/bash
#$ -cwd
# error = Merged with joblog
#$ -o /u/home/x/xinniu/cluster-log-spikeSort/job572-$JOB_ID/joblog_$JOB_ID_$TASK_ID.txt
#$ -j y
## Edit the line below as needed. The data limit applies for each task individually,
## so no need to change it if you submit more array tasks.
#$ -l h_rt=24:00:00,h_data=100G
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

# make a copy of batch script:
cd /u/home/x/xinniu/nwbPipeline/batch
if [ ! -f "runbatch_spikeSorting_$JOB_ID.sh" ]; then
    echo "backup job script: runbatch_spikeSorting_$JOB_ID.sh"
    cp runbatch_spikeSorting.sh runbatch_spikeSorting_$JOB_ID.sh
fi

matlab  -nosplash -nodisplay -singleCompThread <<EOF
    addpath(genpath('/u/home/x/xinniu/nwbPipeline'));
    workingDir = getDirectory();
    expIds = (3: 11);
    filePath = fullfile(workingDir, 'MovieParadigm/573_MovieParadigm');
    skipExist = [0, 0, 0];
    batch_spikeSorting($SGE_TASK_ID, $total_tasks, expIds, filePath, skipExist);
    system(['find ', filePath, ' -user $USER -exec chmod 775 {} \;'])
    exit
EOF

# echo job info on joblog:
echo "Job $JOB_ID ended on:   " `hostname -s`
echo "Job $JOB_ID ended on:   " `date `
echo " "

### extract_clusterless_parallel.job STOP ###
# this site shows how to do array jobs: https://info.hpc.sussex.ac.uk/hpc-guide/how-to/array.html
# (better than the Hoffman site https://www.hoffman2.idre.ucla.edu/Using-H2/Computing/Computing.html#how-to-build-a-submission-script)


 