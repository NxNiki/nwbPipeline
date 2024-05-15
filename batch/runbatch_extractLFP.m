function runbatch_extractLFP(workerId, totalWorkers)

    if nargin < 1
        % run script without queue:
        workerId = 1;
        totalWorkers = 1;
    end

    addpath(genpath('/u/home/x/xinniu/nwbPipeline'));

    expIds = (3:11);
    filePath = '/u/project/ifried/data/PIPELINE_vc/ANALYSIS/MovieParadigm/573_MovieParadigm';

    % expIds = (4: 5);
    % filePath = '/u/project/ifried/xinniu/xin_test/PIPELINE_vc/ANALYSIS/MovieParadigm/570_MovieParadigm';
    % filePath = '/Users/XinNiuAdmin/HoffmanMount/xinniu/xin_test/PIPELINE_vc/ANALYSIS/MovieParadigm/570_MovieParadigm';

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
    [~, spikeFiles] = createSpikeFileName(microFiles(:, 1));
    spikeFiles = cellfun(@(x) fullfile(spikeFilePath, x), spikeFiles, UniformOutput=false);

    lfpFiles = extractLFP(microFiles, timestampFiles, spikeFiles, microLFPPath, '', skipExist, saveRaw);
    writecell(lfpFiles, fullfile(microLFPPath, sprintf('lfpFiles_%d.csv', workerId)));

end




