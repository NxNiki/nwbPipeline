% unpack the macro neuralynx data.

patientId = 570;
expId = 5;

filePath = '/Volumes/DATA/NLData/D570/EXP5_Movie_24_Sleep/2024-01-27_00-01-35';
outFilePath = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/570_MovieParadigm';

%% list csc and event files. 
% csc files are grouped for each channel.
expOutFilePath = [outFilePath, sprintf('/Experiment%d/', expId)];

if ~exist(expOutFilePath, "dir")
    mkdir(expOutFilePath);
end

groupRegPattern = '.*?(?=\_\d{1}|\.ncs)';
suffixRegPattern = '(?<=\_)\d*';
orderByCreateTime = true;

ignoreFilesWithSizeBelow = 16384;

tic
[groups, fileNames, channelFileNames, eventFileNames] = groupFiles(filePath, groupRegPattern, suffixRegPattern, orderByCreateTime, ignoreFilesWithSizeBelow);
toc

writetable(channelFileNames, fullfile(expOutFilePath, 'channelFileNames.csv'));

%% unpack macro files:
macroOutFilePath = [outFilePath, sprintf('/Experiment%d/CSC_macro/', expId)];

if ~exist(macroOutFilePath, "dir")
    mkdir(macroOutFilePath);
end

channelFileNames = readcell(fullfile(expOutFilePath, 'channelFileNames.csv'));
channelFileNames = channelFileNames(2:end,:);

% select macro files and rename output file names so that alphabetic order 
% is consistent with temporal order. The macro files always start with 'R' 
% or 'L' in the file name
macroIdx = cellfun(@(x)~isempty(regexp(x, '^[RL].*[0-9]', 'match', 'once')), channelFileNames(:, 1));
macroFileNames = channelFileNames(macroIdx, :);

writecell(macroFileNames, fullfile(macroOutFilePath, 'macroFileNames.csv'));

inMacroFiles = macroFileNames(:, 2:end);
macroChannles = macroFileNames(:, 1);
numFilesEachChannel = size(inMacroFiles, 2);
suffix = arrayfun(@(y) sprintf('%03d.mat', y), 1:numFilesEachChannel, 'UniformOutput', false);
outMacroFiles = combineCellArrays(macroChannles, suffix);

emptyIdx = cellfun(@isempty, inMacroFiles(:));
tic
unpackData(inMacroFiles(~emptyIdx), outMacroFiles(~emptyIdx), macroOutFilePath)
toc
disp('macro files unpack finished!')

%% unpack micro files:

microOutFilePath = [outFilePath, sprintf('/Experiment%d/CSC_micro/', expId)];

if ~exist(microOutFilePath, "dir")
    mkdir(microOutFilePath);
end

channelFileNames = readcell(fullfile(expOutFilePath, 'channelFileNames.csv'));
channelFileNames = channelFileNames(2:end,:);

microIdx = cellfun(@(x)~isempty(regexp(x, '^G[A-D].*[0-9]', 'match', 'once')), channelFileNames(:, 1));
microFileNames = channelFileNames(microIdx, :);







