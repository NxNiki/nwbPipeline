% unpack the macro and micro blackrock data.

% define filePath, experiment id and outFilePath here or comment it will trigger a UI to
% select paths and experiment id:
clear
scriptDir = fileparts(mfilename('fullpath'));
<<<<<<< HEAD
<<<<<<< HEAD
cd(scriptDir);
=======
>>>>>>> 191feb1 (unpack black rock, add test script)
=======
cd(scriptDir);
>>>>>>> 3749158 (bug unpack black rock data (wip))
addpath(genpath(fileparts(scriptDir)));

%%% ----------- UCLA Data: --------- %%%
skipExist = 0;
expIds = 4;
filePath = {...
    'Screening/574_Screening/',...
    };

outFilePath = 'Screening/574_Screening/';

% montageConfigFile = '/Users/XinNiuAdmin/Documents/MATLAB/nwbPipeline/montageConfig/montage_Patient-1702_exp-46_2024-06-10_16-52-31.json';
montageConfigFile = [];
[renameMacroChannels, renameMicroChannels] = createChannels(montageConfigFile);

for i = 1: length(filePath)
    
    expFilePath = fullfile(outFilePath, sprintf('Experiment-%d', expIds(i)));
    
<<<<<<< HEAD
<<<<<<< HEAD
=======
    % unpack micro channels:
    microFile = dir(fullfile(filePath{i}, '*.ns5'));
    if length(microFile) > 1 || isempty(microFile)
        warning('zero or multiple .ns5 files detected!\n unpack micro for %s is skipped.', filePath{i});
        continue
    end
    
    inFile = fullfile(filePath{i}, microFile.name);
    unpackBlackRock(inFile, expFilePath, renameMicroChannels, skipExist);

>>>>>>> 191feb1 (unpack black rock, add test script)
=======
>>>>>>> 3749158 (bug unpack black rock data (wip))
    % unpack macro channels:
    macroFile = dir(fullfile(filePath{i}, '*.ns3'));
    if length(macroFile) > 1 || isempty(macroFile)
        warning('zero or multiple .ns3 files detected!\n unpack macro for %s is skipped.', filePath{i});
        continue
    end
<<<<<<< HEAD
<<<<<<< HEAD
    inFile = fullfile(filePath{i}, macroFile.name);
    unpackBlackRock(inFile, expFilePath, renameMacroChannels, skipExist);

    % % unpack micro channels:
    % microFile = dir(fullfile(filePath{i}, '*.ns5'));
    % if length(microFile) > 1 || isempty(microFile)
    %     warning('zero or multiple .ns5 files detected!\n unpack micro for %s is skipped.', filePath{i});
    %     continue
    % end
    % inFile = fullfile(filePath{i}, microFile.name);
    % unpackBlackRock(inFile, expFilePath, renameMicroChannels, skipExist);

=======
    
    inFile = fullfile(filePath{i}, macroFile.name);
    unpackBlackRock(inFile, expFilePath, renameMacroChannels, skipExist);

>>>>>>> 191feb1 (unpack black rock, add test script)
=======
    inFile = fullfile(filePath{i}, macroFile.name);
    unpackBlackRock(inFile, expFilePath, renameMacroChannels, skipExist);

    % % unpack micro channels:
    % microFile = dir(fullfile(filePath{i}, '*.ns5'));
    % if length(microFile) > 1 || isempty(microFile)
    %     warning('zero or multiple .ns5 files detected!\n unpack micro for %s is skipped.', filePath{i});
    %     continue
    % end
    % inFile = fullfile(filePath{i}, microFile.name);
    % unpackBlackRock(inFile, expFilePath, renameMicroChannels, skipExist);

>>>>>>> 3749158 (bug unpack black rock data (wip))
end
