% run_extractLFP
clear

expIds = [4:7];
patient = 570;
expName = 'MovieParadigm';

filePath = sprintf('/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/%s/%d_%s', expName, patient, expName);

% 0: will remove all previous extracted files.
% 1: skip existing files.
skipExist = [0, 0];  %[micro, macro]

% save raw data to check spike interpolation (will take huge storage space)
saveRaw = false;

batch_extractLFP(1, 1, expIds, filePath, skipExist);

