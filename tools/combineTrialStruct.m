% combine TTLs:


files = {
    '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/Screening/1809_Screening/Experiment-82/trialStruct.mat';
    '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/Screening/1809_Screening/Experiment-84/trialStruct.mat';
    '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/Screening/1809_Screening/Experiment-86/trialStruct.mat';
    };


outputPath = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/Screening/1809_Screening/Experiment-82-84-86/';
outputFileName = 'trialStruct.mat';

if ~exist(outputPath, "dir")
    mkdir(outputPath);
end

combineVar = cell(1, length(files));

for i = 1:length(files)
    eventFileObj = matfile(files{i});
    combineVar{i} =  eventFileObj.trials;
end

combineVar = cat(2, combineVar{:});

% outFileObj = matfile(fullfile(outputPath, outputFileName));
% outFileObj.trials=  combineVar;

trials = combineVar;

save(fullfile(outputPath, outputFileName), "trials")
