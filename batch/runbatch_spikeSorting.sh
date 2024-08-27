#!/bin/bash
# =========================================
# Script Name: runbatch_spikeSorting.sh
# Description: submit matlab batch jobs to SGE 
# Usage: qsub ./runbatch_spikeSorting.sh
# Parameters:
#   - expName: str, This should be consistent to the file path in unpacked data.
#   - patientId: str, This should be consistent to the file path in unpacked data.
#   - expIds: matlab array, Define experiments to run spike sorting at line 78.
#   - skipExists: 1 by 3 logical matlab array, whether to skip: spikeDetection, spikeCode, spikeClustering.
# =========================================


## Set the SGE parameters (#$ is not a comment, and will be processed before the shell variables are evaluated)
#$ -cwd
# Use the current working directory for the job execution

#$ -o $HOME/sgelog/job-spikeSort-$JOB_ID/task_$TASK_ID.txt
# Redirect the standard output and standard error to a specific file
# $JOB_ID and $TASK_ID are environment variables provided by the scheduler

#$ -j y
# Merge standard error with the job log (standard output)

#$ -l h_rt=10:00:00,h_data=50G
# Request resources: hours of runtime (h_rt) and memory (h_data)
# Data limit applies to each task individually, no need to change if submit more tasks.

#$ -pe shared 8
# Request N core in a shared parallel environment

# Email address to notify
#$ -M $USER@mail
# Set the email address to notify. $USER is an environment variable for the username

# #$ -m bea
# Uncomment to receive email notifications at the beginning (b), end (e), and if the job is aborted (a)

#$ -t 1:15:1
# Array job specification: run tasks with IDs from 1 to N, with a step of 1 (i.e., 1, 2, 3, ..., N)
# Each task will have a unique $TASK_ID


## Set the experiment parameters ==========
expName="MovieParadigm"
patientId="570"
expIds="[4, 5, 6, 7]" 
# if expIds is updated, do not skipExist any steps so that threshodold for spike detection is same across experiments
skipExist="[0, 0, 0]"  # [spike detection, spike code, spike clustering]
runRemovePLI = true

## load the job environment:
. /u/local/Modules/default/init/modules.sh
# To see which versions of matlab are available use: module av matlab
module load matlab/R2023b
codePath="/u/home/x/xinniu/nwbPipeline"


#### DO NOT EDIT THINGS BELOW

total_tasks=$(( ($SGE_TASK_LAST - $SGE_TASK_FIRST) / $SGE_TASK_STEPSIZE + 1 ))

## echo job info on joblog:
echo "Job $JOB_ID started on:   " `hostname -s`
echo "Job $JOB_ID started on:   " `date `
echo " "
echo "Start Matlab"
echo "run spike sorting, task id: $SGE_TASK_ID, total tasks: $total_tasks"


## make a copy of batch script:
# Get the directory containing the currently executing script
cd ${codePath}/batch
if [ ! -d jobs_${expName} ]; then
    mkdir jobs_${expName}
fi

backupScript="jobs_${expName}/runbatch_spikeSorting_${expName}${patientId}_$JOB_ID.sh"
# check if backup script is already saved by previous task:
if [ ! -f $backupScript ]; then
    echo "backup job script: $backupScript"
    cp runbatch_spikeSorting.sh $backupScript
    sed -i '69,85d' $backupScript
    sed -i '43i# THIS IS AUTOMATICALLY GENERATED SCRIPT.' $backupScript
    sed -i '44i# YOU CAN SUBMIT THIS SCRIPT TO RERUN THIS JOB' $backupScript
fi

## run matlab function:
matlab  -nosplash -nodisplay <<EOF
    addpath(genpath('${codePath}'));
    expIds = ${expIds};
    skipExist = ${skipExist};
    workingDir = getDirectory();
    filePath = fullfile(workingDir, '${expName}/${patientId}_${expName}');
    batch_spikeSorting($SGE_TASK_ID, $total_tasks, expIds, filePath, skipExist);
    system(['find ', filePath, ' -user $USER -exec chmod 775 {} \;']);
    exit
EOF

## echo job info on joblog:
echo "Job $JOB_ID ended on:   " `hostname -s`
echo "Job $JOB_ID ended on:   " `date `
echo " "

# this site shows how to do array jobs: https://info.hpc.sussex.ac.uk/hpc-guide/how-to/array.html
# (better than the Hoffman site https://www.hoffman2.idre.ucla.edu/Using-H2/Computing/Computing.html#how-to-build-a-submission-script)