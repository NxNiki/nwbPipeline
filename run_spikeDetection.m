% run spike detection and spike sorting to the unpacked data:

expId = 2;
filePath = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/Screening/555_Screening';

% 0: will remove all previous unpack files.
% 1: skip existing files.
skipExist = 0; 

expOutFilePath = [outFilePath, sprintf('/Experiment%d/', expId)];

%%
macroPattern = '^[RL].*[0-9]';

