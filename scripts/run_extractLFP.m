% run_extractLFP
clear

expIds = [4];
filePath = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/FaceRecognition/486_FaceRecognition';

% 0: will remove all previous extracted files.
% 1: skip existing files.
skipExist = [0, 1];

% save raw data to check spike interpolation (will take huge storage space)
saveRaw = false;

batch_extractLFP(1, 1, expIds, filePath, skipExist);

