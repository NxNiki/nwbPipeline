function unpackConfig = unpackNeuralynxUI()
% set variables (folders, IDs, and paths) to unpack raw .ncs file to .mat.
% see run_unpackNeuralynx.m

close all

selectedFolders = {};
experimentIds = [];
outputFilePath = '';
macroPattern = '*';
microPattern = '*';
eventPattern = 'Events*';
montageConfigFile = [];

unpackConfig = struct();
% generally we won't have memory issue in unpacking unless the raw ncs
% files are combined for sleep experiments.
unpackConfig.numParallelTasks = 10;

defaultBasePath = '/Volumes/DATA/NLData/';
defaultOutputPath = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm';
defaultSaveFile = 'Patient-xx_Exp-xx.json';


% add more patterns for future use:
macroPatternLabel = {
    '^[RL].*[0-9]';         % UCLA data
    '^LFPx*';               % IOWA data
    '';                     % do not unpack macro
    };

microPatternLabel = {
    '^G[A-D].*[0-9]';       % UCLA data
    '^PDes*';               % IOWA data
    '';                     % do not unpack micro
    };

eventPatternLabel = {
    'Events*';
    };


% Create a figure for the GUI
f = figure('Position', [300 300 900 1150], 'Name', 'Folder Selector', ...
    'NumberTitle', 'off', 'Resize', 'on');

%% Unpack Config Panel:
experimentIDPanel = uipanel('Title', 'Unpack Config', 'FontSize', 15, ...
    'Units', 'normalized', 'Position', [0.05 0.73 0.9 0.24]);

right = .02;
height = 0.15;
width = 0.15;
widthEdit = .78;
bottom = 0.75;
expIdLabel = uicontrol('Parent', experimentIDPanel, 'Style', 'text', 'Units', 'normalized', ...
    'Position', [right bottom width height], 'String', 'Experiment ID:', 'FontSize', 15, ...
    'HorizontalAlignment', 'left');

expIdInput = uicontrol('Parent', experimentIDPanel, 'Style', 'edit', 'Units', 'normalized', ...
    'Position', [0.17 bottom + 0.02 widthEdit height], 'String', '', 'FontSize', 15, ...
    'HorizontalAlignment', 'left');

bottom = .55;
widthPopupMenu = 0.175;
macroLabel = uicontrol('Parent', experimentIDPanel, 'Style', 'text', 'Units', 'normalized', ...
    'Position', [right bottom width height], 'String', 'Macro Pattern:', 'FontSize', 15, ...
    'HorizontalAlignment', 'left');

macroPatternInput = uicontrol('Parent', experimentIDPanel, 'Style', 'popupmenu', 'String', macroPatternLabel, ...
    'Units', 'normalized', 'Position', [0.16 bottom widthPopupMenu height], 'FontSize', 15, ...
    'HorizontalAlignment', 'left');

microLabel = uicontrol('Parent', experimentIDPanel, 'Style', 'text', 'Units', 'normalized', ...
    'Position', [.345 bottom width height], 'String', 'Micro Pattern:', 'FontSize', 15, ...
    'HorizontalAlignment', 'left');

microPatternInput = uicontrol('Parent', experimentIDPanel, 'Style', 'popupmenu', 'String', microPatternLabel, ...
    'Units', 'normalized', 'Position', [0.475 bottom widthPopupMenu height], 'FontSize', 15, ...
    'HorizontalAlignment', 'left');

eventLabel = uicontrol('Parent', experimentIDPanel, 'Style', 'text', 'Units', 'normalized', ...
    'Position', [.655 bottom width height], 'String', 'Event Pattern:', 'FontSize', 15, ...
    'HorizontalAlignment', 'left');

eventPatternInput = uicontrol('Parent', experimentIDPanel, 'Style', 'popupmenu', 'String', eventPatternLabel, ...
    'Units', 'normalized', 'Position', [0.78 bottom widthPopupMenu height], 'FontSize', 15, ...
    'HorizontalAlignment', 'left');

bottom = .25;
montageLabel = uicontrol('Parent', experimentIDPanel, 'Style', 'text', 'Units', 'normalized', ...
    'Position', [right bottom width height], 'String', 'Montage File:', 'FontSize', 15, ...
    'HorizontalAlignment', 'left');

montageFileInput = uicontrol('Parent', experimentIDPanel, 'Style', 'edit', 'Units', 'normalized', ...
    'Position', [0.17 bottom + 0.02 widthEdit height], 'String', '', 'FontSize', 15, ...
    'HorizontalAlignment', 'left');

bottom = .075;
outputPathLabel = uicontrol('Parent', experimentIDPanel, 'Style', 'text', 'Units', 'normalized', ...
    'Position', [right bottom width height], 'String', 'Output Path:', 'FontSize', 15, ...
    'HorizontalAlignment', 'left');

% Text box to input the output file path with a default value
outputFilePathInput = uicontrol('Parent', experimentIDPanel, 'Style', 'edit', 'Units', 'normalized', ...
    'Position', [0.17 bottom widthEdit height], 'String', defaultOutputPath, ...
    'FontSize', 15, 'HorizontalAlignment', 'left');

%% Base Directory Panel
basePanel = uipanel('Title', 'Base Directory', 'FontSize', 15, ...
    'Units', 'normalized', 'Position', [0.05 0.65 0.9 0.08]);

% Text box to input the base directory path with a default value
baseDirInput = uicontrol('Parent', basePanel, 'Style', 'edit', 'Units', 'normalized', ...
    'Position', [0.05 0.2 0.9 0.6], 'String', defaultBasePath, ...
    'FontSize', 15, 'HorizontalAlignment', 'left');

%% Folder List Panel
folderPanel = uipanel('Title', 'Select input path', 'FontSize', 15, ...
    'Units', 'normalized', 'Position', [0.05 0.17 0.9 0.48]);

% List box to display selected folders
listBox = uicontrol('Parent', folderPanel, 'Style', 'listbox', 'Units', 'normalized', ...
    'Position', [0.05 0.1 0.9 0.8], 'String', {}, 'FontSize', 15,...
    'Max', 2, 'Min', 0);

% Button to add paths
addButton = uicontrol('Parent', folderPanel, 'Style', 'pushbutton', 'Units', 'normalized', ...
    'Position', [0.05 0.9 0.3 0.07], 'String', 'Add Paths', ...
    'Callback', @addPaths);

% Button to remove a selected path
removeButton = uicontrol('Parent', folderPanel, 'Style', 'pushbutton', 'Units', 'normalized', ...
    'Position', [0.65 0.9 0.3 0.07], 'String', 'Remove Path', ...
    'Callback', @removePath);

% Arrow buttons to reorder the folders
moveUpButton = uicontrol('Parent', folderPanel, 'Style', 'pushbutton', 'Units', 'normalized', ...
    'Position', [0.05 0.01 0.1 0.07], 'String', '↑', ...
    'Callback', @moveUp);

moveDownButton = uicontrol('Parent', folderPanel, 'Style', 'pushbutton', 'Units', 'normalized', ...
    'Position', [0.15 0.01 0.1 0.07], 'String', '↓', ...
    'Callback', @moveDown);

%% Confirm button to finalize the selections
confirmButton = uicontrol('Style', 'pushbutton', 'Units', 'normalized', ...
    'Position', [0.8 0.05 0.15 0.05], 'String', 'Confirm', ...
    'Callback', @confirmSelection);

% Load button to load data from a JSON file
loadButton = uicontrol('Style', 'pushbutton', 'Units', 'normalized', ...
    'Position', [0.65 0.05 0.15 0.05], 'String', 'Load', ...
    'Callback', @loadFromJson);

%% Save Parameters Panel
savePanel = uipanel('Title', 'Save parameters', 'FontSize', 15, ...
    'Units', 'normalized', 'Position', [0.05 0.05 0.6 0.12]);

% Add a checkbox for enabling/disabling JSON saving
saveCheckbox = uicontrol('Parent', savePanel, 'Style', 'checkbox', 'Units', 'normalized', ...
    'Position', [0.05 0.1 0.3 0.3], 'String', 'Save Parameters', ...
    'FontSize', 12, 'Value', 1); % Default to checked

% Add a text field for entering the JSON filename
fileNameInput = uicontrol('Parent', savePanel, 'Style', 'edit', 'Units', 'normalized', ...
    'Position', [0.05 0.4 0.8 0.5], 'String', defaultSaveFile, ...
    'FontSize', 15, 'HorizontalAlignment', 'left');

% Add a checkbox for enabling/disabling skipExist
skipExistCheckbox = uicontrol('Parent', savePanel, 'Style', 'checkbox', 'Units', 'normalized', ...
    'Position', [0.4 0.1 0.3 0.3], 'String', 'Skip Exist', ...
    'FontSize', 12, 'Value', 1); % Default to checked


%% Function to add paths to the list
    function addPaths(~, ~)
        baseDir = get(baseDirInput, 'String');
        folderPath = uigetdir(baseDir, 'Select Folders');
        if folderPath ~= 0
            currentList = get(listBox, 'String');
            set(listBox, 'String', [currentList; {folderPath}]);
        end
    end

%% Function to remove selected paths
    function removePath(~, ~)
        selectedIndex = get(listBox, 'Value');
        if ~isempty(selectedIndex)
            currentList = get(listBox, 'String');
            currentList(selectedIndex) = [];
            set(listBox, 'String', currentList, 'Value', max(1, selectedIndex - 1));
        end
    end

%% Function to move a folder up
    function moveUp(~, ~)
        currentList = get(listBox, 'String');
        selectedIndex = get(listBox, 'Value');
        if ~isempty(selectedIndex) && selectedIndex > 1
            currentList([selectedIndex - 1, selectedIndex]) = currentList([selectedIndex, selectedIndex - 1]);
            set(listBox, 'String', currentList, 'Value', selectedIndex - 1);
        end
    end

%% Function to move a folder down
    function moveDown(~, ~)
        currentList = get(listBox, 'String');
        selectedIndex = get(listBox, 'Value');
        if ~isempty(selectedIndex) && selectedIndex < numel(currentList)
            currentList([selectedIndex, selectedIndex + 1]) = currentList([selectedIndex + 1, selectedIndex]);
            set(listBox, 'String', currentList, 'Value', selectedIndex + 1);
        end
    end

%% Function to add channel pattern label:
    function value = addChannelPattern(newPattern, existPatterns)
        existPatterns = [existPatterns(:); {newPattern}];
        value = length(existPatterns);
    end

%% Confirm Selection Function (also saves to JSON)
    function confirmSelection(~, ~)
        rawIds = get(expIdInput, 'String');
        tempIds = str2num(rawIds);  % Convert to numerical array

        % Validate input for integers
        if isempty(tempIds) && ~isempty(rawIds)
            errordlg('Invalid input for "Experiment Ids". Please enter a valid numerical array.', 'Input Error');
        elseif any(tempIds ~= fix(tempIds))  % Check if any IDs are non-integers
            errordlg('Experiment IDs must be integers. Please correct the input.', 'Input Error');
        else
            % Ensure to update local variables with the current state of the UI
            selectedFolders = get(listBox, 'String');  % Capture the current state of the listBox
            outputFilePath = get(outputFilePathInput, 'String');
            experimentIds = tempIds;  % Update local variable
            fileNameInputString = get(fileNameInput, 'String');
            macroPattern = macroPatternLabel{get(macroPatternInput, 'Value')};
            microPattern = microPatternLabel{get(microPatternInput, 'Value')};
            eventPattern = eventPatternLabel{get(eventPatternInput, 'Value')};
            montageConfigFile = get(montageFileInput, 'String');

            if length(experimentIds) ~= length(selectedFolders)
                msgbox('Length of experiment Id and input Folder not match!', 'Warning', 'warn');
                return
            end

            % Construct the data structure
            unpackConfig.BaseDirectory = get(baseDirInput, 'String');
            unpackConfig.ExperimentIds = experimentIds;
            unpackConfig.OutputFilePath = outputFilePath;
            unpackConfig.SelectedFolders = selectedFolders;  % Ensure this is updated
            unpackConfig.fileNameInput = fileNameInputString;
            unpackConfig.macroPattern = macroPattern;
            unpackConfig.microPattern = microPattern;
            unpackConfig.eventPattern = eventPattern;
            unpackConfig.montageConfigFile = montageConfigFile;
            unpackConfig.skipExist = get(skipExistCheckbox, 'Value');

            % Check if "Save to JSON" is enabled and process accordingly
            if get(saveCheckbox, 'Value') == 1
                jsonFilename = get(fileNameInput, 'String');
                if isempty(jsonFilename)
                    timestamp = datestr(now, 'yyyymmdd_HHMMSS');
                    jsonFilename = sprintf('input_data_%s.json', timestamp);
                else
                    jsonFilename = ensureJsonExtension(jsonFilename);
                end

                % baseDir = getBaseDir();
                % writeJson(unpackConfig, fullfile(baseDir, 'scripts/unpackConfigs', jsonFilename));

                if ~exist(outputFilePath, "dir")
                    mkdir(outputFilePath);
                end
                writeJson(unpackConfig, fullfile(outputFilePath, jsonFilename));
            end

            delete(f);  % Close the window
        end
    end

    function filename = ensureJsonExtension(filename)
        [~, ~, ext] = fileparts(filename);
        if isempty(ext)
            filename = [filename '.json'];
        elseif ~strcmp(ext, '.json')
            filename = [filename(1:end-length(ext)) '.json'];
        end
    end

%% Function to load data from a user-selected JSON file
    function loadFromJson(~, ~)
        [file, path] = uigetfile('*.json', 'Select JSON file to load');
        if file == 0
            return; % User canceled the selection
        end

        fullPath = fullfile(path, file);
        data = readJson(fullPath);

        % Set GUI components with loaded values
        if isfield(data, 'BaseDirectory') && ischar(data.BaseDirectory)
            set(baseDirInput, 'String', data.BaseDirectory);
        end

        if isfield(data, 'ExperimentIds') && isnumeric(data.ExperimentIds)
            set(expIdInput, 'String', num2str(data.ExperimentIds(:)', '%g '));
        end

        if isfield(data, 'OutputFilePath') && ischar(data.OutputFilePath)
            set(outputFilePathInput, 'String', data.OutputFilePath);
        end

        if isfield(data, 'SelectedFolders') && iscell(data.SelectedFolders)
            set(listBox, 'String', data.SelectedFolders);
        end

        if isfield(data, 'fileNameInput') && ischar(data.fileNameInput)
            set(fileNameInput, 'String', data.fileNameInput);
        end

        if isfield(data, 'macroPattern') && ischar(data.macroPattern)
            value = find(ismember(macroPatternLabel, data.macroPattern));
            if isempty(value)
                [value, macroPatternLabel] = addChannelPattern(data.macroPattern, macroPatternLabel);
            end
            set(macroPatternInput, 'Value', value);
        end

        if isfield(data, 'microPattern') && ischar(data.microPattern)
            value = find(ismember(microPatternLabel, data.microPattern));
            if isempty(value)
                [value, microPatternLabel] = addChannelPattern(data.microPattern, microPatternLabel);
            end
            set(microPatternInput, 'Value', value);
        end

        if isfield(data, 'eventPattern') && ischar(data.eventPattern)
            set(eventPatternInput, 'String', data.eventPattern);
        end

        if isfield(data, 'montageConfigFile') && ischar(data.montageConfigFile)
            set(montageFileInput, 'String', data.montageConfigFile);
        end
    end

% Pause execution until user confirms or closes the UI
uiwait(f);
end
