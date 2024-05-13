function runbatch_extractLFP(workerId, totalWorkers)

    if nargin < 1
        % run script without queue:
        workerId = 1;
        totalWorkers = 1;
    end

    addpath(genpath('/u/home/x/xinniu/nwbPipeline'));

    expIds = (3:11);
    filePath = '/u/project/ifried/data/PIPELINE_vc/ANALYSIS/MovieParadigm/573_MovieParadigm';

    % 0: will remove all previous unpack files.
    % 1: skip existing files.
    skipExist = 1;
    saveRaw = false;

    spikeFilePath = [filePath, '/Experiment', sprintf('-%d', expIds)];
    microLFPPath = fullfile(spikeFilePath, 'LFP_micro');

    %% micro electrodes:
    microFiles = [];
    timestampFiles = [];
    for i = 1: length(expIds)
        expId = expIds(i);
        cscFilePath = [filePath, sprintf('/Experiment%d', expId)];
        microFilePath = fullfile(cscFilePath, 'CSC_micro');

        % save filenames for micro files to csv as there may be multiple segments in a single experiment.
        % files for a single channel will be in the same row.
        microFilesExp = readcell(fullfile(microFilePath, 'outFileNames.csv'), Delimiter=",");
        microFilesExp = cellfun(@(x)replacePath(x, microFilePath), microFilesExp, UniformOutput=false);
        microFiles = [microFiles, microFilesExp];

        timestampFilesExp = dir(fullfile(microFilePath, 'lfpTimeStamps*.mat'));
        timestampFiles = [timestampFiles, fullfile(microFilePath, {timestampFilesExp.name})];
    end

    jobIds = splitJobs(size(microFiles, 1), totalWorkers, workerId);
    if isempty(jobIds)
        disp("No job assigned to batch! This is due to more workers than number of micro files.")
        return
    end

    disp(['jobIds: ', sprintf('%d ', jobIds)]);
    microFiles = microFiles(jobIds, :);
    fprintf(['microFiles: \n', sprintf('%s\n', microFiles{:})]);

    % delete(gcp('nocreate'))
    % parpool(3); % each channel will take nearly 20GB memory for multi-exp analysis.

    spikeFilePath = fullfile(spikeFilePath, 'CSC_micro_spikes');
    [~, spikeFiles] = createSpikeFileName(microFiles(:, 1));
    spikeFiles = cellfun(@(x) fullfile(spikeFilePath, x), spikeFiles, UniformOutput=false);

    lfpFiles = extractLFP(microFiles, timestampFiles, spikeFiles, microLFPPath, '', skipExist, saveRaw);
    writecell(lfpFiles, fullfile(microLFPPath, sprintf('lfpFiles_%d.csv', workerId));

end

function fullPath = replacePath(fullPath, replacePath)
    [~, fileName, ext] = fileparts(fullPath);
    fullPath = [replacePath, filesep, fileName, ext];
end



