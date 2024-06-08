% unpack the macro neuralynx data.
% this script should run with Matlab 2023a or earlier if on Mac with apple
% silicon.

% define filePath, experiment id and outFilePath here or comment it will trigger a UI to
% select paths and experiment id:
clear
scriptDir = fileparts(mfilename('fullpath'));
addpath(genpath(fileparts(scriptDir)));

%%% ----------- UCLA Data: --------- %%%
% expIds = [3: 11];
% filePath = {...
%     '/Volumes/DATA/NLData/D573/EXP3_PreSleep_Movie24_Control_1_Home_Improvement/2024-05-03_20-54-34',...
%     '/Volumes/DATA/NLData/D573/EXP4_PreSleep_Movie24_Control_2_Top_Gun/2024-05-03_21-30-59', ...
%     '/Volumes/DATA/NLData/D573/EXP5_PreSleep_Movie24_Control_3_Lion_King/2024-05-03_21-56-23', ...
%     '/Volumes/DATA/NLData/D573/EXP6_PreSleep_Movie24_Control_4_Quentin_Johnson/2024-05-03_22-14-34', ...
%     '/Volumes/DATA/NLData/D573/EXP7_PreSleep_Movie24_Viewing/2024-05-03_22-28-34', ...
%     '/Volumes/DATA/NLData/D573/EXP8_PreSleep_Movie24_Memory/2024-05-03_23-16-37', ...
%     '/Volumes/DATA/NLData/D573/EXP9_Movie24_Sleep/2024-05-03_23-50-25', ...
%     '/Volumes/DATA/NLData/D573/EXP10_PostSleep_Movie24_Memory/2024-05-04_08-48-41', ...
%     '/Volumes/DATA/NLData/D573/EXP11_PostSleep_Movie24_Control_Free_Recall/2024-05-04_09-42-25', ...
%     };
% 
% outFilePath = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/573_MovieParadigm';

%%% -------- Iowa Data: ----------- %%%
% expIds = [43, 44, 45, 46, 47, 50];
% filePath = {...
%     '/Volumes/DATA/NLData/i728R/728-043_UCLA Control Videos/2023-12-11_16-02-08', ...
%     '/Volumes/DATA/NLData/i728R/728-044_UCLA Control Video Walking Dead/2023-12-11_16-22-45', ...
%     '/Volumes/DATA/NLData/i728R/728-045_UCLA Movie 24/2023-12-11_17-06-47', ...
%     '/Volumes/DATA/NLData/i728R/728-046_UCLA Movie 24 Recall/2023-12-11_18-48-32', ...
%     '/Volumes/DATA/NLData/i728R/728-047_EEG_WatchPat_Overnight/2023-12-11_19-31-40', ...
%     '/Volumes/DATA/NLData/i728R/728-050_Movie 24 Recall/2023-12-12_15-03-49', ...
%     };
% outFilePath = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/1728_MovieParadigm';

%%% -------- for testing: --------- %%%
% expIds = [4:5];
% filePath = {...
%     '/Users/XinNiuAdmin/HoffmanMount/xinniu/xin_test/RAW_NLX/D570/EXP4_Movie_24_Pre_Sleep/2024-01-26_20-46-57', ...
%     '/Users/XinNiuAdmin/HoffmanMount/xinniu/xin_test/RAW_NLX/D570/EXP5_Movie_24_Sleep/2024-01-27_00-01-35', ...
%     };
% 
% outFilePath = '/Users/XinNiuAdmin/HoffmanMount/xinniu/xin_test/PIPELINE_vc/ANALYSIS/MovieParadigm/570_MovieParadigm';

skipExist = 1;
macroPattern = '^[RL].*[0-9]';
microPattern = '^G[A-D].*[0-9]';

% macroPattern = '^LFPx*';
% microPattern = '^PDes*';

%%% read montage setting to rename output file names
% this is used on IOWA data on which .ncs files are named differently.
% montageConfigFile = '/Users/XinNiuAdmin/Documents/MATLAB/nwbPipeline/montageConfig/montage_Patient-1728_exp-43.json';
montageConfigFile = [];

%%% define number of task in parfor:
% generally we won't have memory issue in unpacking unless the raw ncs
% files are combined for sleep experiments. 
numParallelTasks = 4;
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
    expOutFilePath = [outFilePath, sprintf('/Experiment%d/', expId)];

    if ~exist(expOutFilePath, "dir")
        mkdir(expOutFilePath);
    end

    %% list csc and event files.
    % csc files are grouped for each channel.

    % groupRegPattern = '.*?(?=\_\d{1}|\.ncs)';
    groupRegPattern = '.*?(?=\_\d{1}|\.ncs)';
    suffixRegPattern = '(?<=\_)\d*';
    orderByCreateTime = true;

    ignoreFilesWithSizeBelow = 16384;

    tic
    [groups, fileNames, channelFileNames, eventFileNames] = groupFiles(filePath{i}, groupRegPattern, suffixRegPattern, orderByCreateTime, ignoreFilesWithSizeBelow);
    toc

    writetable(channelFileNames, fullfile(expOutFilePath, 'channelFileNames.csv'));

    %% unpack macro files:

    macroOutFilePath = [outFilePath, sprintf('/Experiment%d/CSC_macro/', expId)];
    [inMacroFiles, outMacroFiles] = createIOFiles(macroOutFilePath, expOutFilePath, macroPattern, renameMacroChannels);

    tic
    unpackData(inMacroFiles, outMacroFiles, macroOutFilePath, 1, skipExist);
    toc
    disp('macro files unpack finished!')

    %% unpack micro files:

    microOutFilePath = [outFilePath, sprintf('/Experiment%d/CSC_micro/', expId)];
    [inMicroFiles, outMicroFiles] = createIOFiles(microOutFilePath, expOutFilePath, microPattern, renameMicroChannels);

    tic
    unpackData(inMicroFiles, outMicroFiles, microOutFilePath, 1, skipExist);
    toc
    disp('micro files unpack finished!')

end





