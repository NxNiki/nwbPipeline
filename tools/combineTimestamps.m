% combine events:
% this is used for screening analysis on iowa data with multiple segments.


files = {
    '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/Screening/1789_Screening/Experiment-28/CSC_micro/lfpTimeStamps_001.mat';
    '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/Screening/1789_Screening/Experiment-29/CSC_micro/lfpTimeStamps_001.mat';
    };


outputPath = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/Screening/1789_Screening/Experiment-28-29/CSC_micro/';
outputFileName = 'lfpTimeStamps_001.mat';

if ~exist(outputPath, "dir")
    mkdir(outputPath);
end

timestamps = cell(1, length(files));

for i = 1:length(files)
    fileObj = matfile(files{i});
    timestamps{i} =  fileObj.timeStamps;
end

timestamps = cat(2, timestamps{:});

outFileObj = matfile(fullfile(outputPath, outputFileName), "Writable", true);
outFileObj.timeStamps = timestamps;
outFileObj.timeend = timestamps(end) - timestamps(1);
outFileObj.time0 = 0;
outFileObj.samplingIntervalSeconds = fileObj.samplingIntervalSeconds;
