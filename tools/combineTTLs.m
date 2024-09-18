% combine TTLs:


eventFiles = {
    '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/Screening/1809_Screening/Experiment-82/TTLs.mat';
    '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/Screening/1809_Screening/Experiment-84/TTLs.mat';
    '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/Screening/1809_Screening/Experiment-86/TTLs.mat';
    };


outputPath = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/Screening/1809_Screening/Experiment-82-84-86/';
outputFileName = 'TTLs.mat';

if ~exist(outputPath, "dir")
    mkdir(outputPath);
end

TTLs = cell(1, length(eventFiles));

for i = 1:length(eventFiles)
    eventFileObj = matfile(eventFiles{i});
    TTLs{i} =  eventFileObj.TTLs;
end

TTLs = cat(1, TTLs{:});

outFileObj = matfile(fullfile(outputPath, outputFileName));
outFileObj.TTLs=  TTLs;
