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

    addpath(genpath('/u/home/x/xinniu/nwbPipeline'));

    % expIds = (3: 11);
    % filePath = '/u/project/ifried/data/PIPELINE_vc/ANALYSIS/MovieParadigm/573_MovieParadigm';
    
    expIds = (4: 5);
    filePath = '/u/project/ifried/xinniu/xin_test/PIPELINE_vc/ANALYSIS/MovieParadigm/570_MovieParadigm';

    % 0: will remove all previous unpack files.
    % 1: skip existing files.
    skipExist = 1;

    microFiles = [];
    timestampFiles = [];
    expNamesId = 1;

    for i = 1:length(expIds)
        expFilePath = [filePath, '/Experiment', sprintf('%d/', expIds(i))];
        microFilePath = fullfile(expFilePath, 'CSC_micro');
        microFiles = [microFiles, readcell(fullfile(microFilePath, 'outFileNames.csv'), Delimiter=",")];
        timestampFile = dir(fullfile(microFilePath, 'lfpTimeStamps*.mat'));
        timestampFiles = [timestampFiles, fullfile(microFilePath, {timestampFile.name})];
        expNames(expNamesId: length(timestampFiles)) = {sprintf('Exp%d', expIds(i))};
        expNamesId = length(timestampFiles) + 1;
    end

    jobIds = splitJobs(size(microFiles, 1), totalWorkers, workerId);

    if isempty(jobIds)
        disp("No job assigned to batch! This is due to more workers than number of micro files.")
        return
    end

    microFiles = microFiles(jobIds);

    %% spike detection:
    delete(gcp('nocreate'))
    parpool(2); % each channel will take nearly 30GB memory for multi-exp analysis.

    expFilePath = [filePath, '/Experiment', sprintf('-%d', expIds)];
    outputPath = fullfile(expFilePath, 'CSC_micro_spikes');

    spikeFiles = spikeDetection(microFiles, timestampFiles, outputPath, expNames, skipExist);
    disp('Spike Detection Finished!')

    %% spike clustering:
    spikeClustering(spikeFiles, outputPath, skipExist);
    disp('Spike Clustering finished!')

end


