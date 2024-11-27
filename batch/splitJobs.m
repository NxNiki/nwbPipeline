function taskIds = splitJobs(numTasks, maxNumWorkers, workerId, channelsPerBundle)
    % assign n tasks to m workers and return the id of tasks for a specific worker.
    % workerId and taskId starts from 1.
    % channelsPerBundle: we always have 8 mico channels in a bundle, channels in a single bundle should be assigned to
    % same job so that cross channel spikeCode calculation is done correctly.

    if nargin < 4
        channelsPerBundle = 8;
    end

    if mod(numTasks, channelsPerBundle) ~= 0
        warning("number of tasks should be a multiple of %d", channelsPerBundle);
    end

    taskPerWorker = floor(numTasks / maxNumWorkers);
    taskPerWorker = ceil(taskPerWorker / channelsPerBundle) * channelsPerBundle;
    workersNeeded = ceil(numTasks / taskPerWorker);

    if workerId > workersNeeded
        taskIds = [];
        return
    end

    startJobId = taskPerWorker * (workerId - 1) + 1;
    taskIds = startJobId: min(startJobId + taskPerWorker - 1, numTasks);

    if mod(length(taskIds) , channelsPerBundle) ~= 0
        warning('number of tasks in each job should be multiple of %d to ensure channels in same bundle are procossed together', channelsPerBundle);
    end

end
