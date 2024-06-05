function [selectedFolders, experimentIds, outputFilePath] = folderSelectionUI()
% set variables (folders, IDs, and paths) to unpack raw .ncs file to .mat.
% see run_unpackNeuralynx.m


selectedFolders = {};
experimentIds = [];
outputFilePath = '';

defaultBasePath = '/Volumes/DATA/NLData/';
defaultOutputPath = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm';
defaultSaveFile = 'Patient-xx_Exp-xx.json';

% Create a figure for the GUI
f = figure('Position', [300 300 600 650], 'Name', 'Folder Selector', ...
    'NumberTitle', 'off', 'Resize', 'on');

%% Experiment ID Panel
experimentIDPanel = uipanel('Title', 'Experiment Ids', 'FontSize', 15, ...
    'Units', 'normalized', 'Position', [0.05 0.85 0.9 0.1]);

% Text box to input the array of experiment IDs
expIdInput = uicontrol('Parent', experimentIDPanel, 'Style', 'edit', 'Units', 'normalized', ...
    'Position', [0.05 0.2 0.9 0.6], 'String', '', 'FontSize', 15, ...
    'HorizontalAlignment', 'left');

%% Output File Path Panel
outputPanel = uipanel('Title', 'Output File Path', 'FontSize', 15, ...
    'Units', 'normalized', 'Position', [0.05 0.75 0.9 0.1]);

% Text box to input the output file path with a default value
outputFilePathInput = uicontrol('Parent', outputPanel, 'Style', 'edit', 'Units', 'normalized', ...
    'Position', [0.05 0.2 0.9 0.6], 'String', defaultOutputPath, ...
    'FontSize', 15, 'HorizontalAlignment', 'left');

%% Base Directory Panel
basePanel = uipanel('Title', 'Base Directory', 'FontSize', 15, ...
    'Units', 'normalized', 'Position', [0.05 0.65 0.9 0.1]);

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
    'FontSize', 10, 'Value', 1); % Default to checked

% Add a text field for entering the JSON filename
fileNameInput = uicontrol('Parent', savePanel, 'Style', 'edit', 'Units', 'normalized', ...
    'Position', [0.05 0.4 0.8 0.5], 'String', defaultSaveFile, ...
    'FontSize', 15, 'HorizontalAlignment', 'left');

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

            % Construct the data structure
            data = struct();
            data.BaseDirectory = get(baseDirInput, 'String');
            data.ExperimentIds = experimentIds;
            data.OutputFilePath = outputFilePath;
            data.SelectedFolders = selectedFolders;  % Ensure this is updated
            data.fileNameInput = fileNameInputString;

            % Check if "Save to JSON" is enabled and process accordingly
            if get(saveCheckbox, 'Value') == 1
                jsonFilename = get(fileNameInput, 'String');
                if isempty(jsonFilename)
                    timestamp = datestr(now, 'yyyymmdd_HHMMSS');
                    jsonFilename = sprintf('input_data_%s.json', timestamp);
                else
                    jsonFilename = ensureJsonExtension(jsonFilename);
                end

                writeJson(data, jsonFilename)
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
    end

% Pause execution until user confirms or closes the UI
uiwait(f);
end
