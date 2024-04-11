function extractLFP(cscFiles, timestampFiles, outputPath, experimentName, skipExist)

if nargin < 4 || isempty(experimentName)
    experimentName = '';
end

if nargin < 5
    skipExist = false;
end


inputPath = fileparts(cscFiles{1});

if ~exist(outputPath, "dir")
    mkdir(outputPath);
elseif ~skipExist && ~strcmp(inputPath, outputPath)
    % create an empty dir to avoid not able to resume with unprocessed
    % files in the future if this job fails. e.g. if we have 10 files
    % processed in t1, t2 stops with 5 files processed, we cannot start
    % with the 6th file in t3 as we have 10 files saved.
    rmdir(outputPath, 's');
    mkdir(outputPath);
end


parfor i = 1: size(cscFiles, 1)
    
    channelFiles = cscFiles(i,:);
    fprintf(['spike detection: \n', sprintf('%s \n', channelFiles{:})])

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
    [cscSignal, timestamps, samplingInterval] = combineCSC(channelFiles(i, :), timestampFiles);

    % TO DO:
    cscSignal = removeSpikes(cscSignal);

    [lfpSignal, downSampledTimestamps, timestampsStart] = antiAliasing(cscSignal, timestamps);

    lfpFileObj = matfile(lfpFilename, "Writable", true);
    lfpFileObj.lfp = lfpSignal;
    lfpFileObj.timestamps = downSampledTimestamps;
    lfpFileObj.experimentName = experimentName;
    lfpFileObj.timestampsStart = timestampsStart;

end

