function runbatch_spikeSorting(workerId, totalWorkers)
    % run spike detection and spike sorting to the unpacked data:

    if nargin < 1
        % run script without queue:
        workerId = 1;
        totalWorkers = 1;
    end

    if workerId > totalWorkers
        disp("workerId larger than number of workers! batch exit.")
        return
    end

    addpath(genpath(fileparts(fileparts(mfilename('fullpath')))));
    workingDir = getDirectory();

    expIds = (4:7);
    filePath = fullfile(workingDir, 'MovieParadigm/570_MovieParadigm');

    %% load file names micro data:
    
    [microFiles, timestampFiles, expNames] = readFilePath(expIds, filePath);
    jobIds = splitJobs(size(microFiles, 1), totalWorkers, workerId);

    if isempty(jobIds)
        disp("No job assigned to batch! This is due to more workers than number of micro files.")
        return
    end

    disp(['jobIds: ', sprintf('%d ', jobIds)]);
    microFiles = microFiles(jobIds, :);
    fprintf(['microFiles: \n', sprintf('%s\n', microFiles{:})]);

    %% spike detection:

    skipExist = 1;
    expFilePath = [filePath, '/Experiment', sprintf('-%d', expIds)];
    outputPath = fullfile(expFilePath, 'CSC_micro_spikes');

    if isempty(gcp('nocreate'))
        parpool('local', 1);  % Adjust the number of workers as needed
    end

    spikeFiles = spikeDetection(microFiles, timestampFiles, outputPath, expNames, skipExist);
    disp('Spike Detection Finished!')

    %% spike clustering:

    skipExist = 1;
    spikeCodeFiles = getSpikeCodes(spikeFiles, outputPath, skipExist);

    spikeClustering(spikeFiles, spikeCodeFiles, outputPath, skipExist);
    disp('Spike Clustering Finished!')

end


