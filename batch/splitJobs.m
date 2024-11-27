function taskIds = splitJobs(numTasks, maxNumWorkers, workerId, channelsPerHeadstage)
    % assign n tasks to m workers and return the id of tasks for a specific worker.
    % workerId and taskId starts from 1.
    % channelsPerHeadstage: we always have 8 mico channels in a headstage, channels in a single headstage should be assigned to
    % same job so that cross channel spikeCode calculation is done correctly.

    if nargin < 4
        channelsPerHeadstage = 8;
    end

    if mod(numTasks, channelsPerHeadstage) ~= 0
        warning("number of tasks should be a multiple of %d", channelsPerHeadstage);
    end

    taskPerWorker = floor(numTasks / maxNumWorkers);
    taskPerWorker = ceil(taskPerWorker / channelsPerHeadstage) * channelsPerHeadstage;
    workersNeeded = ceil(numTasks / taskPerWorker);

    if workerId > workersNeeded
        taskIds = [];
        return
    end

    startJobId = taskPerWorker * (workerId - 1) + 1;
    taskIds = startJobId: min(startJobId + taskPerWorker - 1, numTasks);

    if mod(length(taskIds) , channelsPerHeadstage) ~= 0
        warning('number of tasks in each job should be multiple of %d to ensure channels in same headstage are procossed together', channelsPerHeadstage);
    end

end
