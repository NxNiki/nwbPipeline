function extractLFP(cscFiles, timestampFiles, spikeFiles, outputPath, experimentName, skipExist)

if nargin < 5 || isempty(experimentName)
    experimentName = '';
end

if nargin < 6
    skipExist = false;
end


makeOutputPath(cscFiles, outputPath, skipExist)

for i = 1: size(cscFiles, 1)
    
    channelFiles = cscFiles(i,:);
    fprintf(['extract LFP: \n', sprintf('%s \n', channelFiles{:})])

    [~, channelFilename] = fileparts(channelFiles{1});
    lfpFilename = fullfile(outputPath, [regexp(channelFilename, '.*(?=_\d+)', 'match', 'once'), '_lfp.mat']);
    
    % TO DO: check file completeness:
    if exist(lfpFilename, "file") && skipExist
        continue
    end

    % it is better if we can combine the data at 32kHz then filter,
    % to reduce edge effects - especially for the sleep data 
    % (for data that is separated in time there will be edge effects either way)
    % but this will take a lot of memory
    [cscSignal, timestamps, samplingInterval] = combineCSC(channelFiles, timestampFiles);

    if ~isempty(spikeFiles) && exist(spikeFiles{i}, "file")
        spikeFileObj = matfile(spikeFiles{i});
        spikes = spikeFileObj.spikes;
        spikeClass = spikeFileObj.cluster_class(:, 1);
        spikeTimestamps = spikeFileObj.cluster_class(:, 2);
    
        cscSignal = removeSpikes(cscSignal, timestamps, spikes, spikeClass, spikeTimestamps);
    else
        fprintf('spike remove spikes, %s not found!\n', spikeFiles{i})
    end

    [lfpSignal, downSampledTimestamps, timestampsStart] = antiAliasing(cscSignal, timestamps);

    lfpFileObj = matfile(lfpFilename, "Writable", true);
    lfpFileObj.lfp = lfpSignal;
    lfpFileObj.timestamps = downSampledTimestamps;
    lfpFileObj.experimentName = experimentName;
    lfpFileObj.timestampsStart = timestampsStart;

end

