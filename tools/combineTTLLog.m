% combine events:


files = {
    '/Volumes/DATA/NLData/i789L/789-028_UCLA_Screen2/789-22-Nov-2024-10-1-30/from laptop/TTLs789-22-Nov-2024-10-1-30_room4.mat';
    '/Volumes/DATA/NLData/i789L/789-029_UCLA_Screen2/789-22-Nov-2024-10-37-21/from laptop/TTLs789-22-Nov-2024-10-37-21_room4.mat';
    };


outputPath = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/Screening/1789_Screening/Experiment-28-29/CSC_events/';
outputFileName = 'ttlLog.mat';

if ~exist(outputPath, "dir")
    mkdir(outputPath);
end

ttlLogs = cell(1, length(files));
timestamps = cell(1, length(files));

for i = 1:length(files)
    fileObj = matfile(files{i});
    ttlLogs{i} =  fileObj.ttlLog;
end

ttlLogs = cat(1, ttlLogs{:});

outFileObj = matfile(fullfile(outputPath, outputFileName));
outFileObj.ttlLog=  ttlLogs;
