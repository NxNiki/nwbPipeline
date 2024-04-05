% unpack the macro neuralynx data.

% expId = 5;
% filePath = '/Volumes/DATA/NLData/D570/EXP5_Movie_24_Sleep/2024-01-27_00-01-35';
% outFilePath = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/570_MovieParadigm';

expId = 2;
filePath = '/Volumes/DATA/NLData/D555/EXP2_Screening/2022-07-31_12-46-04';
outFilePath = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/Screening/555_Screening';

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
macroPattern = '^[RL].*[0-9]';
[inMacroFiles, outMacroFiles] = createIOFiles(macroOutFilePath, expOutFilePath, macroPattern);

tic
unpackData(inMacroFiles, outMacroFiles, macroOutFilePath, 1, skipExist);
toc
disp('macro files unpack finished!')

%% unpack micro files:

microOutFilePath = [outFilePath, sprintf('/Experiment%d/CSC_micro/', expId)];
microPattern = '^G[A-D].*[0-9]';
[inMacroFiles, outMacroFiles] = createIOFiles(microOutFilePath, expOutFilePath, microPattern);

tic
unpackData(inMicroFiles, outMicroFiles, microOutFilePath, 1, skipExist);
toc
disp('macro files unpack finished!')





