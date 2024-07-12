#!/bin/bash
# =========================================
# Script Name: runbatch_extractLFP.sh
# Description: submit matlab batch jobs to SGE 
# Usage: qsub ./runbatch_extractLFP.sh
# Parameters:
#   - expName: str, This should be consistent to the file path in unpacked data.
#   - patientId: str, This should be consistent to the file path in unpacked data.
#   - expIds: matlab array, Define experiments to run spike sorting at line 78.
#   - skipExists: 1 by 2 logical matlab array, whether to skip LFP extraction for micro and macro channels, respectively
# =========================================


## Set the SGE parameters (#$ is not a comment, and will be processed before the shell variables are evaluated)
#$ -cwd
# Use the current working directory for the job execution

#$ -o $HOME/sgelog/job-lfpExtract-$JOB_ID/task_$TASK_ID.txt
# Redirect the standard output and standard error to a specific file
# $JOB_ID and $TASK_ID are environment variables provided by the scheduler

#$ -j y
# Merge standard error with the job log (standard output)

#$ -l h_rt=24:00:00,h_data=200G
# Request resources: 24 hours of runtime (h_rt) and 100GB of memory (h_data)
# Data limit applies to each task individually, no need to change if submit more tasks.

#$ -pe shared 1
# Request 1 core in a shared parallel environment

# Email address to notify
#$ -M $USER@mail
# Set the email address to notify. $USER is an environment variable for the username

# #$ -m bea
# Uncomment to receive email notifications at the beginning (b), end (e), and if the job is aborted (a)

#$ -t 1:10:1
# Array job specification: run tasks with IDs from 1 to 10, with a step of 1 (i.e., 1, 2, 3, ..., 10)
# Each task will have a unique $TASK_ID


## Set the experiment parameters ==========
expName="MovieParadigm"
patientId="573"

## Set MATLAB parameters
expIds="[3:11]"  # MATLAB array format
skipExist="[1, 0]"  # MATLAB logical array


## load the job environment:
. /u/local/Modules/default/init/modules.sh
# To see which versions of matlab are available use: module av matlab
module load matlab/R2023b

#### DO NOT EDIT THINGS BELOW

total_tasks=$(( ($SGE_TASK_LAST - $SGE_TASK_FIRST) / $SGE_TASK_STEPSIZE + 1 ))

## echo job info on joblog:
echo "Job $JOB_ID started on:   " `hostname -s`
echo "Job $JOB_ID started on:   " `date `
echo " "
echo "Start Matlab"
echo "run LFP extraction, task id: $SGE_TASK_ID, total tasks: $total_tasks"


## make a copy of batch script:
cd /u/home/x/xinniu/nwbPipeline/batch
if [ ! -d jobs_${expName} ]; then
    mkdir jobs_${expName}
fi

backupScript="jobs_${expName}/runbatch_extractLFP_${expName}${patientId}_$JOB_ID.sh"
# check if backup script is already saved by previous task:
if [ ! -f $backupScript ]; then
    echo "backup job script: $backupScript"
    cp runbatch_extractLFP.sh $backupScript
    sed -i '13i# THIS IS AUTOMATICALLY GENERATED SCRIPT.' $backupScript
    sed -i '14i# YOU CAN SUBMIT THIS SCRIPT TO RERUN THIS JOB' $backupScript
    sed -i '69,83d' $backupScript
fi

## run matlab function:
matlab  -nosplash -nodisplay -singleCompThread <<EOF
    addpath(genpath('/u/home/x/xinniu/nwbPipeline'));
    expIds = ${expIds};
    skipExist = ${skipExist};
    workingDir = getDirectory();
    filePath = fullfile(workingDir, '${expName}/${patientId}_${expName}');
    batch_extractLFP($SGE_TASK_ID, $total_tasks, expIds, filePath, skipExist);
    system(['find ', filePath, ' -user $USER -exec chmod 775 {} \;']);
    exit
EOF

## echo job info on joblog:
echo "Job $JOB_ID ended on:   " `hostname -s`
echo "Job $JOB_ID ended on:   " `date `
echo " "

# this site shows how to do array jobs: https://info.hpc.sussex.ac.uk/hpc-guide/how-to/array.html
# (better than the Hoffman site https://www.hoffman2.idre.ucla.edu/Using-H2/Computing/Computing.html#how-to-build-a-submission-script)