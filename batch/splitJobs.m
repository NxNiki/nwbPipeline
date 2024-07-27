function taskIds = splitJobs(numTasks, numWorkers, workerId)
    % assign n tasks to m workers and return the id of tasks for a specific worker.
    % workerId and taskId starts from 1.

    if numWorkers >= numTasks
        if workerId <= numTasks
            taskIds = workerId;
        else
            taskIds = [];
        end
        return
    end

    taskPerWorker = floor(numTasks / numWorkers);
    extraTasks = mod(numTasks, numWorkers);

    if workerId <= extraTasks
        taskPerWorker = taskPerWorker + 1;
        startJobId = taskPerWorker * (workerId - 1) + 1;
    else
        startJobId = taskPerWorker * (workerId - 1) + 1 + extraTasks;
    end
    
    taskIds = startJobId: min(startJobId + taskPerWorker - 1, numTasks);

end
