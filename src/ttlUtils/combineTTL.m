function TTLCombined = combineTTL(filePath, expIds)

    timestampsFile = fullfile(filePath, ['Experiment', sprintf('-%d', expIds)], 'LFP_micro', 'lfpTimestamps.mat');
    timestampsFileObj = matfile(timestampsFile);
    timestampsStart = timestampsFileObj.timestampsStart;

    TTLCombined = [];
    for i = 1:length(expIds)

        trialFile = fullfile(filePath, sprintf('Experiment-%d', expIds(i)), 'trialStruct.mat');

        if ~exist(trialFile, "file")
            warning("file not exist: %s\n", trialFile);
            continue;
        end

        trialFile = matfile(trialFile);
        trials = trialFile.trials;

        % correct timestamps:
        trials = arrayfun(@(s) setfield(s, 'trialStartTime', s.trialStartTime - timestampsStart), trials);
        trials = arrayfun(@(s) setfield(s, 'trialEndTime', s.trialEndTime - timestampsStart), trials);

        TTLCombined = [TTLCombined(:); trials(:)];

    end

    TTLCombined = removeEmptyFields(TTLCombined, {'NA'}, {'trialStartTimeMat', 'trialEndTimeMat'});

    % Rename fields for start and stop times to ensure compatibility with the NWB Trial object.
    TTLCombined = renameStructField(TTLCombined, {'trialStartTime', 'trialEndTime'}, {'start_time', 'stop_time'});

end
