% unpack the macro neuralynx data.

patientId = 570;
expId = 5;

filePath = '/Volumes/DATA/NLData/D570/EXP5_Movie_24_Sleep/2024-01-27_00-01-35';
outFilePath = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/570_MovieParadigm';

filePath = '/Volumes/DATA/NLData/D570/EXP5_Movie_24_Sleep/2024-01-27_00-01-35';
outFilePath = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/570_MovieParadigm';

% 0: will remove all previous unpack files.
% 1: skip existing files.
skipExist = 0; 

expOutFilePath = [outFilePath, sprintf('/Experiment%d/', expId)];

%% list csc and event files. 
% csc files are grouped for each channel.

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
elseif ~skipExist
    % create an empty dir to avoid not able to resume with unprocessed
    % files in the future if this job fails. e.g. if we have 10 files
    % processed in t1, t2 stops with 5 files processed, we cannot start
    % with the 6th file in t3 as we have 10 files saved.
    rmdir(macroOutFilePath, 's');
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
macroChannels = macroFileNames(:, 1);
numFilesEachChannel = size(inMacroFiles, 2);
suffix = arrayfun(@(y) sprintf('%03d.mat', y), 1:numFilesEachChannel, 'UniformOutput', false);
outMacroFiles = combineCellArrays(macroChannels, suffix);

emptyIdx = cellfun(@isempty, inMacroFiles(:));
tic
unpackData(inMacroFiles(~emptyIdx), outMacroFiles(~emptyIdx), macroOutFilePath, 1, skipExist)
toc
disp('macro files unpack finished!')

%% unpack micro files:

% microOutFilePath = [outFilePath, sprintf('/Experiment%d/CSC_micro/', expId)];
% 
% if ~exist(microOutFilePath, "dir")
%     mkdir(microOutFilePath);
% elseif ~skipExist
%     % create an empty dir to avoid not able to skip exist if failure occurs
%     % during running:
%     rmdir(microOutFilePath, 's');
%     mkdir(microOutFilePath);
% end
% 
% channelFileNames = readcell(fullfile(expOutFilePath, 'channelFileNames.csv'));
% channelFileNames = channelFileNames(2:end,:);
% 
% microIdx = cellfun(@(x)~isempty(regexp(x, '^G[A-D].*[0-9]', 'match', 'once')), channelFileNames(:, 1));
% microFileNames = channelFileNames(microIdx, :);
% 
% writecell(microFileNames, fullfile(microOutFilePath, 'macroFileNames.csv'));
% 
% inMicroFiles = microFileNames(:, 2:end);
% microChannels = microFileNames(:, 1);
% numFilesEachChannel = size(inMicroFiles, 2);
% suffix = arrayfun(@(y) sprintf('%03d.mat', y), 1:numFilesEachChannel, 'UniformOutput', false);
% outMicroFiles = combineCellArrays(microChannels, suffix);
% 
% emptyIdx = cellfun(@isempty, inMicroFiles(:));
% tic
% unpackData(inMicroFiles(~emptyIdx), outMicroFiles(~emptyIdx), microOutFilePath)
% toc
% disp('macro files unpack finished!')





