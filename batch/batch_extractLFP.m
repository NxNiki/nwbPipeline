function batch_extractLFP(workerId, totalWorkers, expIds, filePath, skipExist)
    % extract LFP after spike detection and clustering (spike sorting).
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

    if nargin < 3
        addpath(genpath(fileparts(fileparts(mfilename('fullpath')))));
        workingDir = getDirectory();

        expIds = (4:7);
        filePath = fullfile(workingDir, 'MovieParadigm/570_MovieParadigm');

        skipExist = 0;
    end
    saveRaw = false;

    spikeFilePath = [filePath, '/Experiment', sprintf('-%d', expIds)];
    microLFPPath = fullfile(spikeFilePath, 'LFP_micro');

    %% micro electrodes:
    [microFiles, timestampFiles] = readFilePath(expIds, filePath);

    jobIds = splitJobs(size(microFiles, 1), totalWorkers, workerId);
    if isempty(jobIds)
        disp("No job assigned to batch! This is due to more workers than number of micro files.")
        return
    end

    disp(['jobIds: ', sprintf('%d ', jobIds)]);
    microFiles = microFiles(jobIds, :);
    fprintf(['microFiles: \n', sprintf('%s\n', microFiles{:})]);

    spikeFilePath = fullfile(spikeFilePath, 'CSC_micro_spikes');
    [spikeDetectFiles, spikeClusterFiles] = createSpikeFileName(microFiles(:, 1));
    spikeDetectFiles = cellfun(@(x) fullfile(spikeFilePath, x), spikeDetectFiles, UniformOutput=false);
    spikeClusterFiles = cellfun(@(x) fullfile(spikeFilePath, x), spikeClusterFiles, UniformOutput=false);

    lfpFiles = extractLFP(microFiles, timestampFiles, spikeDetectFiles, spikeClusterFiles, microLFPPath, '', skipExist, saveRaw);
    writecell(lfpFiles, fullfile(microLFPPath, sprintf('lfpFiles_%d.csv', workerId)));

    disp('lfp extraction finished!');

end




