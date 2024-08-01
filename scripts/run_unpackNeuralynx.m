% unpack the macro and micro neuralynx data.
% this script should run with Matlab 2023a or earlier if on Mac with apple
% silicon.

clear
scriptDir = fileparts(mfilename('fullpath'));
addpath(genpath(fileparts(scriptDir)));

% define filePath, experiment id and outFilePath here or comment it will trigger a UI to
% select paths and experiment id:
%%% ----------- UCLA Data: --------- %%%
% expIds = [3: 5];
% filePath = {...
%     '/Volumes/DATA/NLData/D573/EXP3_PreSleep_Movie24_Control_1_Home_Improvement/2024-05-03_20-54-34',...
%     '/Volumes/DATA/NLData/D573/EXP4_PreSleep_Movie24_Control_2_Top_Gun/2024-05-03_21-30-59', ...
%     '/Volumes/DATA/NLData/D573/EXP5_PreSleep_Movie24_Control_3_Lion_King/2024-05-03_21-56-23', ...
%     };
% 
% outFilePath = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/573_MovieParadigm';

% TO DO: read unpack config file to skip UI.

skipExist = 1;

% patterns should not include file extension such as .ncs or .nev
macroPattern = '^[RL].*[0-9]';
% macroPattern = []; % do not need to unpack macro in screening analysis.
microPattern = '^G[A-D].*[0-9]';

% macroPattern = '^LFPx*';
% microPattern = '^PDes*';

eventPattern = 'Events*';

%%% read montage setting to rename output file names
% this is used on IOWA data on which .ncs files are named differently.
montageConfigFile = '/Users/XinNiuAdmin/Documents/MATLAB/nwbPipeline/montageConfig/montage_Patient-1721_exp-92_2024-08-01_14-59-54.json';
% montageConfigFile = [];

%%% define number of task in parfor:
% generally we won't have memory issue in unpacking unless the raw ncs
% files are combined for sleep experiments. 
numParallelTasks = 8;
% numParallelTasks = [];

%%
if ~exist("filePath", "var") || isempty(filePath)
    [filePath, expIds, outFilePath] = folderSelectionUI();
end

if ~isempty(numParallelTasks)
    delete(gcp('nocreate'))
    parpool(numParallelTasks);
end

[renameMacroChannels, renameMicroChannels] = createChannels(montageConfigFile);

for i = 1:length(expIds)

    expId = expIds(i);
    expOutFilePath = [outFilePath, sprintf('/Experiment-%d/', expId)];

    if ~exist(expOutFilePath, "dir")
        mkdir(expOutFilePath);
    end

    %% list csc and event files.
    % csc files are grouped for each channel.

    groupRegPattern = '.*?(?=\_\d{1}|\.ncs)';
    suffixRegPattern = '(?<=\_)\d*';
    orderByCreateTime = true;

    ignoreFilesWithSizeBelow = 16384;

    if ~exist(fullfile(expOutFilePath, 'channelFileNames.csv'), 'file') || ~skipExist
        tic
        [groups, fileNames, channelFileNames] = groupFiles(filePath{i}, groupRegPattern, suffixRegPattern, orderByCreateTime, ignoreFilesWithSizeBelow);
        writetable(channelFileNames, fullfile(expOutFilePath, 'channelFileNames.csv'));
        toc
    end

    %% unpack Event Files:
    eventOutFilePath = [outFilePath, sprintf('/Experiment-%d/CSC_events', expId)];
    [inEventFiles, outEventFiles] = createIOFiles(eventOutFilePath, expOutFilePath, eventPattern);
    
    tic
    unpackData(inEventFiles, outEventFiles, eventOutFilePath, 1, skipExist);
    toc
    disp('event files unpack finished!')

    %% unpack macro files:

    if ~isempty(macroPattern)
        macroOutFilePath = [outFilePath, sprintf('/Experiment-%d/CSC_macro/', expId)];
        [inMacroFiles, outMacroFiles] = createIOFiles(macroOutFilePath, expOutFilePath, macroPattern, renameMacroChannels);
    
        tic
        unpackData(inMacroFiles, outMacroFiles, macroOutFilePath, 1, skipExist);
        toc
        disp('macro files unpack finished!')
    end

    %% unpack micro files:

    if ~isempty(microPattern)
        microOutFilePath = [outFilePath, sprintf('/Experiment-%d/CSC_micro/', expId)];
        [inMicroFiles, outMicroFiles] = createIOFiles(microOutFilePath, expOutFilePath, microPattern, renameMicroChannels);
    
        tic
        unpackData(inMicroFiles, outMicroFiles, microOutFilePath, 1, skipExist);
        toc
        disp('micro files unpack finished!')
    end

end





