% move intermediate results to LTS
clear

addpath(genpath('/Users/XinNiuAdmin/Documents/MATLAB/nwbPipeline'));

expIds = (3:11);
filePath = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/573_MovieParadigm';
backupPath = '/Volumes/DATA/HoffmanBackup/MovieParadigm/570_MovieParadigm';
removeSource = true;

%% backup files

[microFiles, timestampFiles] = readFilePath(expIds, filePath);

backupFiles(microFiles, backupPath, removeSource);
backupFiles(timestampFiles, backupPath, removeSource);







