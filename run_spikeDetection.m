% run spike detection and spike sorting to the unpacked data:

% expId = 2;
% filePath = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/Screening/555_Screening';

expId = 5;
filePath = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/570_MovieParadigm';

% 0: will remove all previous unpack files.
% 1: skip existing files.
skipExist = 0; 

expFilePath = [filePath, sprintf('/Experiment%d/', expId)];

%%

microFilePath = fullfile(expFilePath, 'CSC_micro');

microFiles = readcell(fullfile(microFilePath, 'outFileNames.csv'), Delimiter=",");
timestampFiles = dir(fullfile(microFilePath, 'lfpTimeStamps*.mat'));
timestampFiles = fullfile(microFilePath, {timestampFiles.name});

microFiles = microFiles(1:2,:);

for i = 1: size(microFiles, 1)
    channelMicroFiles = microFiles(i,:);
    tic
    fprintf(['combine csc signals: \n', sprintf('%s \n', channelMicroFiles{:})]);
    [signal, timestamps, samplingInterval] = combineCSC(channelMicroFiles, timestampFiles);
    toc

    % spike detection:
    param = set_parameters();
    param.sr = seconds(1)/samplingInterval;
    param.ref = floor(1.5 * param.sr/1000); 
    
    tic
    fprintf('spike detection on: %s\n', microFiles{i, 1});
    [spikes,detectionParams,index] = amp_detect(x, param);
    toc

end

    



