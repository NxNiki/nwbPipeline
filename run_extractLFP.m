% run_extractLFP

% expId = 2;
% filePath = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/Screening/555_Screening';

% expId = 5;
% filePath = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/570_MovieParadigm';

expId = 1;
filePath = '/Users/XinNiuAdmin/Documents/NWBTest/output/Screening/550_Screening';

% 0: will remove all previous unpack files.
% 1: skip existing files.
skipExist = 1; 

expFilePath = [filePath, sprintf('/Experiment%d/', expId)];

%%