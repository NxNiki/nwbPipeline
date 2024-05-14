function taskIds = splitJobs(numTasks, numWorkers, workerId)
    % assign n tasks to m workers and return the id of tasks for a specific worker.
    % workerId starts from 1.

    if numWorkers >= numTasks
        if workerId <= numTasks
            taskIds = workerId;
        else
            taskIds = [];
        return
    end

    taskPerWorker = ceil(numTasks / numWorkers);
    startJobId = taskPerWorker * (workerId - 1) + 1;
    taskIds = startJobId: min(startJobId + taskPerWorker - 1, numTasks);

end
