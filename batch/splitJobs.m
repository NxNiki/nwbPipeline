function jobIds = splitJobs(numTasks, numWorkers, workerId)
    % assign n tasks to m workers and return the id of tasks for a specific worker.
    % workerId starts from 1.

    if numWorkers >= numTasks
        jobIds = workerId;
        return
    end

    taskPerWorker = floor(numTasks / numWorkers);
    startJobId = taskPerWorker * (workerId - 1) + 1;
    jobIds = startJobId: min(tartJobId + taskPerWorker, numTasks);

end
