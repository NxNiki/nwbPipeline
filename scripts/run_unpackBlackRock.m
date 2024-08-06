% unpack the macro and micro blackrock data.

% define filePath, experiment id and outFilePath here or comment it will trigger a UI to
% select paths and experiment id:
clear
scriptDir = fileparts(mfilename('fullpath'));
addpath(genpath(fileparts(scriptDir)));

skipExist = 0;
expIds = 4;
filePath = {...
    '/Volumes/DATA/NLData/D574/EXP4_Screening2/20240720-173300/',...
    };

outFilePath = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/Screening/574_Screening/';

% montageConfigFile = '/Users/XinNiuAdmin/Documents/MATLAB/nwbPipeline/montageConfig/montage_Patient-1702_exp-46_2024-06-10_16-52-31.json';
montageConfigFile = [];
[renameMacroChannels, renameMicroChannels] = createChannels(montageConfigFile);

for i = 1: length(filePath)
    
    expFilePath = fullfile(outFilePath, sprintf('Experiment-%d', expIds(i)));
    
    % unpack micro channels:
    microFile = dir(fullfile(filePath{i}, '*.ns5'));
    if length(microFile) > 1 || isempty(microFile)
        warning('zero or multiple .ns5 files detected!\n unpack micro for %s is skipped.', filePath{i});
        continue
    end
    
    inFile = fullfile(filePath{i}, microFile.name);
    unpackBlackRock(inFile, expFilePath, renameMicroChannels, skipExist);

    % unpack macro channels:
    macroFile = dir(fullfile(filePath{i}, '*.ns3'));
    if length(macroFile) > 1 || isempty(macroFile)
        warning('zero or multiple .ns3 files detected!\n unpack macro for %s is skipped.', filePath{i});
        continue
    end
    
    inFile = fullfile(filePath{i}, macroFile.name);
    unpackBlackRock(inFile, expFilePath, renameMacroChannels, skipExist);

end
