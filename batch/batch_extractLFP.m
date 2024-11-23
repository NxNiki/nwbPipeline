function batch_extractLFP(workerId, totalWorkers, expIds, filePath, skipExist)
    % extract LFP after spike detection and clustering (spike sorting).

    if isempty(workerId) || isempty(totalWorkers)
        % run script without queue:
        workerId = 1;
        totalWorkers = 1;
    end

    if workerId > totalWorkers
        disp("workerId larger than number of workers! batch exit.")
        return
    end

    if length(skipExist) == 1
        skipExist = [skipExist, skipExist];
    end
    
    saveRaw = false;
    lfpFs = 2000; % Hz;

    expFilePath = [filePath, '/Experiment', sprintf('-%d', expIds)];

    %% save down sampled timestamps for micro and macro channels:
    microLFPPath = fullfile(expFilePath, 'LFP_micro');
    macroLFPPath = fullfile(expFilePath, 'LFP_macro');

    [microFiles, microTimestampFiles] = readFilePath(expIds, filePath, 'micro');
    [macroFiles, macroTimestampFiles] = readFilePath(expIds, filePath, 'macro');

    lfpTimestamps = downsampleTimestamps(microTimestampFiles, macroTimestampFiles, lfpFs, expFilePath);

    %% micro electrodes:
    jobIds = splitJobs(size(microFiles, 1), totalWorkers, workerId);
    if isempty(jobIds)
        disp("No job assigned to batch! This is due to more workers than number of micro files.");
    else
        disp(['micro jobIds: ', sprintf('%d ', jobIds)]);
        microFiles = microFiles(jobIds, :);
        fprintf(['microFiles: \n', sprintf('%s\n', microFiles{:})]);
    
        spikeFilePath = fullfile(expFilePath, 'CSC_micro_spikes');
        [spikeDetectFiles, spikeClusterFiles] = createSpikeFileName(microFiles(:, 1));
        spikeDetectFiles = cellfun(@(x) fullfile(spikeFilePath, x), spikeDetectFiles, UniformOutput=false);
        spikeClusterFiles = cellfun(@(x) fullfile(spikeFilePath, x), spikeClusterFiles, UniformOutput=false);
    
        lfpFiles = extractLFP(microFiles, microTimestampFiles, lfpTimestamps, spikeDetectFiles, spikeClusterFiles, microLFPPath, skipExist(1), saveRaw);
        writecell(lfpFiles, fullfile(microLFPPath, sprintf('lfpFiles_job%d.csv', workerId)));
    
        disp('micro lfp extraction finished!');
    end

    %% macro electrodes:
    jobIds = splitJobs(size(macroFiles, 1), totalWorkers, workerId);
    if isempty(jobIds)
        disp("No job assigned to batch! This is due to more workers than number of macro files.")
    else
        disp(['macro jobIds: ', sprintf('%d ', jobIds)]);
        macroFiles = macroFiles(jobIds, :);
        fprintf(['macroFiles: \n', sprintf('%s\n', macroFiles{:})]);
    
        lfpFiles = extractLFP(macroFiles, macroTimestampFiles, lfpTimestamps, '', '', macroLFPPath, skipExist(2), saveRaw);
        writecell(lfpFiles, fullfile(macroLFPPath, sprintf('lfpFiles_job%d.csv', workerId)));
    
        disp('macro lfp extraction finished!');
    end

end




