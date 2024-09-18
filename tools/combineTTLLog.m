% combine events:


files = {
    '/Volumes/DATA/NLData/i809R/809_Screening1/809/809-16-Sep-2024-11-6-19/from laptop/TTLs809-16-Sep-2024-11-6-19_room2.mat';
    '/Volumes/DATA/NLData/i809R/809_Screening1/809/809-16-Sep-2024-13-57-10/from laptop/TTLs809-16-Sep-2024-13-57-10_room3.mat';
    '/Volumes/DATA/NLData/i809R/809_Screening1/809/809-17-Sep-2024-9-58-22/from laptop/TTLs809-17-Sep-2024-9-58-22_room3.mat';
    };


outputPath = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/Screening/1809_Screening/Experiment-82-84-86/CSC_events/';
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
