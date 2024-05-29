function runbatch_spikeSorting(workerId, totalWorkers)
    % run spike detection and spike sorting to the unpacked data:
    % run can modify this script and run on different patients/exp when
    % at least one previous job is running (a temporary job script is created).

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

    expIds = (8:14);
    filePath = fullfile(workingDir, 'MovieParadigm/572_MovieParadigm');
    skipExist = [1, 1, 1];

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

    expFilePath = [filePath, '/Experiment', sprintf('-%d', expIds)];
    outputPath = fullfile(expFilePath, 'CSC_micro_spikes');

    if isempty(gcp('nocreate'))
        parpool('local', 1);  % Adjust the number of workers as needed
    end

    spikeFiles = spikeDetection(microFiles, timestampFiles, outputPath, expNames, skipExist(1));
    disp('Spike Detection Finished!')

    %% spike clustering:

    spikeCodeFiles = getSpikeCodes(spikeFiles, outputPath, skipExist(2));

    spikeClustering(spikeFiles, spikeCodeFiles, outputPath, skipExist(3));
    disp('Spike Clustering Finished!')

end


