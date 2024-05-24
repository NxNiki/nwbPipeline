function runbatch_extractLFP(workerId, totalWorkers)

    if nargin < 1
        % run script without queue:
        workerId = 1;
        totalWorkers = 1;
    end

    addpath(genpath(fileparts(pwd)));
    workingDir = getDirectory();

    expIds = (4:7);
    filePath = fullfile(workingDir, 'MovieParadigm/570_MovieParadigm');

    % 0: will remove all previous unpack files.
    % 1: skip existing files.
    skipExist = 1;
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




