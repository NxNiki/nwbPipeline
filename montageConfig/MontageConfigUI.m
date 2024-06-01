function MontageConfigUI()
    % Create a figure for the UI
    f = figure('Position', [100, 100, 1000, 900], 'Name', 'Montage Setup');

    % ------------------- Experiment Info Panel ------------------- %

    expInfoPanel = uipanel('Parent', f, 'Title', 'Experiment Info', ...
                           'Position', [0.05, 0.9, 0.9, 0.065], 'FontSize', 12);

    % Patient ID
    uicontrol('Parent', expInfoPanel, 'Style', 'text', 'String', 'Patient ID:', ...
              'Units', 'normalized', 'Position', [0.01, 0.2, 0.1, 0.6], 'HorizontalAlignment', 'left', 'FontSize', 12);
    patientIDEdit = uicontrol('Parent', expInfoPanel, 'Style', 'edit', ...
                              'Units', 'normalized', 'Position', [0.12, 0.2, 0.1, 0.6], 'FontSize', 12, ...
                              'Callback', @updateFileNames);

    % Experiment ID
    uicontrol('Parent', expInfoPanel, 'Style', 'text', 'String', 'Experiment ID:', ...
              'Units', 'normalized', 'Position', [0.25, 0.2, 0.1, 0.6], 'HorizontalAlignment', 'left', 'FontSize', 12);
    experimentIDEdit = uicontrol('Parent', expInfoPanel, 'Style', 'edit', ...
                                 'Units', 'normalized', 'Position', [0.36, 0.2, 0.1, 0.6], 'FontSize', 12, ...
                                 'Callback', @updateFileNames);

    % ------------------- Montage Panel ------------------- %

    montagePanel = uipanel('Parent', f, 'Title', 'Micro Channels', ...
                           'Position', [0.05, 0.125, 0.55, 0.77], 'FontSize', 12);

    % Brain labels
    brainLabels = {'RA', 'LA', 'RAI', 'LAI', 'ROF', 'LOF', 'RAC', 'LAC', 'RPHG', 'LPHG', 'RAH', 'LAH', 'RLSA', 'RLSS', 'RLSP'};
    customBrainLabel = 'Custom';

    % Default headstage labels
    defaultHeadstageLabels = {'GA', 'GB', 'GC', 'GD'};

    numHeadstages = 4;
    numPortsPerHeadstage = 4;
    headstageHandles = cell(numHeadstages, numPortsPerHeadstage + 1, 3); % Handles for micros, brain labels, custom label edit, and headstage label
    defaultNumChannelsMicro = '8';

    for headstageIdx = 1:numHeadstages
        row = floor((headstageIdx - 1) / 2);
        col = mod(headstageIdx - 1, 2);
        headstagePanel = uipanel('Parent', montagePanel, 'Title', ['Headstage ' num2str(headstageIdx)], ...
                            'Units', 'normalized', 'Position', [0.027 + 0.485 * col, 0.5 - 0.49 * row, 0.46, 0.48], 'FontSize', 12);

        % Headstage label
        uicontrol('Parent', headstagePanel, 'Style', 'text', 'String', 'Label:', ...
                  'Units', 'normalized', 'Position', [0.01, 0.82, 0.2, 0.1], 'HorizontalAlignment', 'left', 'FontSize', 12);
        headstageLabelEdit = uicontrol('Parent', headstagePanel, 'Style', 'edit', 'String', defaultHeadstageLabels{headstageIdx}, ...
                                  'Units', 'normalized', 'Position', [0.22, 0.85, 0.3, 0.1], 'FontSize', 12);
        % Headstage checkbox
        headstageCheckbox = uicontrol('Parent', headstagePanel, 'Style', 'checkbox', 'Value', 1, ...
                                 'Units', 'normalized', 'Position', [0.55, 0.85, 0.4, 0.1], 'String', 'Enable', 'FontSize', 12, ...
                                 'Callback', @(src, event)toggleHeadstageFields(headstageIdx, src));

        headstageHandles{headstageIdx, numPortsPerHeadstage + 1, 1} = headstageLabelEdit; % Store headstage label handle
        headstageHandles{headstageIdx, numPortsPerHeadstage + 1, 2} = headstageCheckbox;

        for portIdx = 1:numPortsPerHeadstage
            % Port label
            uicontrol('Parent', headstagePanel, 'Style', 'text', 'String', ['Port ' num2str(portIdx)], ...
                      'Units', 'normalized', 'Position', [0.01, 0.71 - 0.2 * (portIdx - 1), 0.2, 0.08], 'HorizontalAlignment', 'left', 'FontSize', 12);
            % Number of Micros
            uicontrol('Parent', headstagePanel, 'Style', 'text', 'String', 'Micros:', ...
                      'Units', 'normalized', 'Position', [0.6, 0.72 - 0.2 * (portIdx - 1), 0.2, 0.08], 'HorizontalAlignment', 'left', 'FontSize', 12);
            microsEdit = uicontrol('Parent', headstagePanel, 'Style', 'edit', 'String', defaultNumChannelsMicro, ...
                                   'Units', 'normalized', 'Position', [0.78, 0.73 - 0.2 * (portIdx - 1), 0.1, 0.07], 'FontSize', 12, ...
                                   'Callback', @validateNumChannels);
            % Brain label
            brainLabelPopup = uicontrol('Parent', headstagePanel, 'Style', 'popupmenu', 'String', [brainLabels, {customBrainLabel}], ...
                                        'Units', 'normalized', 'Position', [0.22, 0.70 - 0.2 * (portIdx - 1), 0.35, 0.1], 'FontSize', 12, ...
                                        'Callback', @(src, event)customBrainLabelCallback(src, headstageIdx, portIdx));

            % Custom label edit field (initially hidden)
            customLabelEdit = uicontrol('Parent', headstagePanel, 'Style', 'edit', 'String', '', ...
                                        'Units', 'normalized', 'Position', [0.22, 0.63 - 0.2 * (portIdx - 1), 0.5, 0.085], 'FontSize', 12, ...
                                        'Visible', 'off');

            headstageHandles{headstageIdx, portIdx, 1} = microsEdit;
            headstageHandles{headstageIdx, portIdx, 2} = brainLabelPopup;
            headstageHandles{headstageIdx, portIdx, 3} = customLabelEdit;
        end
    end

    % ------------------- Macro Channels Panel ------------------- %

    channelPanel = uipanel('Parent', f, 'Title', 'Macro Channels', ...
                           'Position', [0.61, 0.125, 0.34, 0.77], 'FontSize', 12);

    % Select all checkbox
    selectAllCheckbox = uicontrol('Parent', channelPanel, 'Style', 'checkbox', 'String', 'Select All', ...
                                  'Units', 'normalized', 'Position', [0.05, 0.95, 0.4, 0.04], 'Callback', @selectAllRows, 'FontSize', 12);

    % Create the table for additional channels
    channelTable = uitable('Parent', channelPanel, 'Units', 'normalized', 'Position', [0.05, 0.12, 0.9, 0.83], ...
            'ColumnName', {'', 'Label', '# of Electrodes'}, 'ColumnEditable', [true, true, true], 'Data', createDefaultTableData(), ...
            'CellEditCallback', @updateChannelData);

    % Add listeners for mouse clicks and key presses
    set(channelTable, 'CellSelectionCallback', @cellSelectionCallback);
    set(channelTable, 'KeyPressFcn', @keyPressCallback);
    set(channelTable, 'KeyReleaseFcn', @keyReleaseCallback);
    
    % Initialize last selected row and Shift key state
    setappdata(channelTable, 'lastSelectedRow', []);
    setappdata(channelTable, 'isShiftPressed', false);

    % Add/Remove rows buttons
    uicontrol('Parent', channelPanel, 'Style', 'pushbutton', 'String', 'Add Row', ...
              'Units', 'normalized', 'Position', [0.05, 0.01, 0.4, 0.04], 'Callback', @addRow, 'FontSize', 12);
    uicontrol('Parent', channelPanel, 'Style', 'pushbutton', 'String', 'Remove Row', ...
              'Units', 'normalized', 'Position', [0.55, 0.01, 0.4, 0.04], 'Callback', @removeRow, 'FontSize', 12);
    uicontrol('Parent', channelPanel, 'Style', 'pushbutton', 'String', 'Move Up', ...
              'Units', 'normalized', 'Position', [0.05, 0.06, 0.4, 0.04], 'Callback', @moveUp, 'FontSize', 12);
    uicontrol('Parent', channelPanel, 'Style', 'pushbutton', 'String', 'Move Down', ...
              'Units', 'normalized', 'Position', [0.55, 0.06, 0.4, 0.04], 'Callback', @moveDown, 'FontSize', 12);

    % ------------------- Save Config Panel ------------------- %

    saveConfigPanel = uipanel('Parent', f, 'Title', 'Save Config', ...
                              'Position', [0.05, 0.04, 0.9, 0.08], 'FontSize', 12);

    % File name inputs
    montageFileName = uicontrol('Parent', saveConfigPanel, 'Style', 'edit', ...
                                'String', 'montage_Patient-_exp-.json', ...
                                'Units', 'normalized', 'Position', [0.01, 0.12, 0.38, 0.6], 'FontSize', 12);

    configFileName = uicontrol('Parent', saveConfigPanel, 'Style', 'edit', ...
                               'String', 'config_Patient-_exp-.cfg', ...
                               'Units', 'normalized', 'Position', [0.4, 0.12, 0.4, 0.6], 'FontSize', 12);

    % ------------------- Load and Confirm buttons ------------------- %

    uicontrol('Parent', saveConfigPanel, 'Style', 'pushbutton', 'String', 'Load', ...
              'Units', 'normalized', 'Position', [0.82, 0.1, 0.08, 0.8], 'Callback', @loadConfigFile, 'FontSize', 12);
    uicontrol('Parent', saveConfigPanel, 'Style', 'pushbutton', 'String', 'Confirm', ...
              'Units', 'normalized', 'Position', [0.91, 0.1, 0.08, 0.8], 'Callback', @saveConfig, 'FontSize', 12);

    % ------------------- callback functions ------------------- %

    function data = createDefaultTableData()
        % Create default table data with brain labels and misc macros
        miscMacros = {'C3', 'C4', 'PZ', 'Ez', 'EOG1', 'EOG2', 'EMG1', 'EMG2', 'A1', 'A2', ...
                      'MICROPHONE', 'HR_Ref', 'HR', 'TTLRef', 'TTLSync', 'Analogue1', 'Analogue2'};
        data = cell(length(brainLabels) + length(miscMacros), 3);
        for i = 1:length(brainLabels)
            data{i, 1} = false;
            data{i, 2} = brainLabels{i};
            data{i, 3} = 8;
        end
        for i = 1:length(miscMacros)
            data{length(brainLabels) + i, 1} = false;
            data{length(brainLabels) + i, 2} = miscMacros{i};
            data{length(brainLabels) + i, 3} = 1;
        end
    end

    function updateFileNames(~, ~)
        % Update the default file names based on Patient ID and Experiment ID
        patientID = get(patientIDEdit, 'String');
        experimentID = get(experimentIDEdit, 'String');
        set(montageFileName, 'String', ['montage_Patient-' patientID '_exp-' experimentID '.json']);
        set(configFileName, 'String', ['config_Patient-' patientID '_exp-' experimentID '.cfg']);
    end

    function validateNumChannels(hObject, ~)
        % Callback to validate input as a number between 1 and 8
        str = get(hObject, 'String');
        num = str2double(str);
        if isnan(num) || num < 0 || num > 8 || floor(num) ~= num
            errordlg('Input must be a number between 0 and 8', 'Invalid Input', 'modal');
            set(hObject, 'String', '8');  % Reset to default value of 8 if invalid
        end
    end

    function toggleHeadstageFields(headstageIdx, checkbox)
        % Enable/disable headstage fields based on checkbox state
        for portIdx = 1:numPortsPerHeadstage
            if get(checkbox, 'Value') == 1
                set(headstageHandles{headstageIdx, portIdx, 1}, 'Enable', 'on');
                set(headstageHandles{headstageIdx, portIdx, 2}, 'Enable', 'on');
                set(headstageHandles{headstageIdx, portIdx, 3}, 'Enable', 'on');
            else
                set(headstageHandles{headstageIdx, portIdx, 1}, 'Enable', 'off');
                set(headstageHandles{headstageIdx, portIdx, 2}, 'Enable', 'off');
                set(headstageHandles{headstageIdx, portIdx, 3}, 'Enable', 'off');
            end
        end
    end

    function customBrainLabelCallback(src, headstageIdx, portIdx)
        % Callback for brain label selection
        selectedLabel = src.String{src.Value};
        if strcmp(selectedLabel, customBrainLabel)
            set(headstageHandles{headstageIdx, portIdx, 3}, 'Visible', 'on');
        else
            set(headstageHandles{headstageIdx, portIdx, 3}, 'Visible', 'off');
        end
    end

    function loadConfigFile(~, ~)
        % Function to load configuration file
        [file, path] = uigetfile('*.json', 'Select Configuration File');
        if isequal(file, 0)
            disp('User selected Cancel');
        else
            filename = fullfile(path, file);
            disp(['User selected ', filename]);
            fid = fopen(filename);
            raw = fread(fid, inf);
            str = char(raw');
            fclose(fid);
            config = jsondecode(str);
            populateUI(config);
        end
    end

    function populateUI(config)
        % Populate the UI with loaded configuration
        set(patientIDEdit, 'String', config.PatientID);
        set(experimentIDEdit, 'String', config.ExperimentID);
        updateFileNames();

        headstages = fieldnames(config.Headstages);
        for i = 1:numHeadstages
            headstageLabel = headstages{i};
            set(headstageHandles{i, 1, 3}, 'String', headstageLabel);
            ports = config.Headstages.(headstageLabel);
            portFields = fieldnames(ports);

            if isempty(portFields)
                set(headstageHandles{i, numPortsPerHeadstage + 1, 1}, 'Value', 0);
                toggleHeadstageFields(i, headstageHandles{i, numPortsPerHeadstage + 1, 2})
                continue
            end

            for j = 1:numPortsPerHeadstage
                portData = ports.(portFields{j});
                set(headstageHandles{i, j, 1}, 'String', num2str(portData.Micros));
                brainLabelIdx = find(strcmp(brainLabels, portData.BrainLabel));
                if isempty(brainLabelIdx)
                    brainLabelIdx = length(brainLabels) + 1; % Custom label
                    set(headstageHandles{i, j, 2}, 'Value', brainLabelIdx);
                    set(headstageHandles{i, j, 3}, 'String', portData.BrainLabel, 'Visible', 'on');
                else
                    set(headstageHandles{i, j, 2}, 'Value', brainLabelIdx);
                    set(headstageHandles{i, j, 3}, 'Visible', 'off');
                end
            end
        end

        % Load additional channels
        channelData = cell(length(config.AdditionalChannels), 3);
        for i = 1:length(config.AdditionalChannels)
            channelData{i, 1} = false;
            channelData{i, 2} = config.AdditionalChannels{i}.Label;
            channelData{i, 3} = config.AdditionalChannels{i}.NumberOfElectrodes;
        end
        set(channelTable, 'Data', channelData);
    end

    function saveConfig(~, ~)
        % Function to save config files
        patientID = get(patientIDEdit, 'String');
        experimentID = get(experimentIDEdit, 'String');
        updateFileNames();
        montageFileNameStr = get(montageFileName, 'String');

        % Create a structure to hold the configuration
        config = struct();
        config.PatientID = patientID;
        config.ExperimentID = experimentID;
        config.Headstages = struct();

        microChannels = {};
        for headstageIdx = 1:numHeadstages
            headstageLabel = get(headstageHandles{headstageIdx, numPortsPerHeadstage + 1, 1}, 'String');
            sanitizedHeadstageLabel = matlab.lang.makeValidName(headstageLabel);  % Sanitize headstage label to make it a valid field name
            config.Headstages.(sanitizedHeadstageLabel) = struct();

            for portIdx = 1:numPortsPerHeadstage
                if strcmp(get(headstageHandles{headstageIdx, portIdx, 1}, 'Enable'), 'on')
                    micros = get(headstageHandles{headstageIdx, portIdx, 1}, 'String');
                    brainLabel = brainLabels{get(headstageHandles{headstageIdx, portIdx, 2}, 'Value')};
                    if get(headstageHandles{headstageIdx, portIdx, 2}, 'Value') == length(brainLabels) + 1
                        brainLabel = get(headstageHandles{headstageIdx, portIdx, 3}, 'String');
                    end
                    config.Headstages.(sanitizedHeadstageLabel).(['Port' num2str(portIdx)]) = struct( ...
                        'Micros', str2double(micros), ...
                        'BrainLabel', brainLabel);

                    if str2double(micros) > 0
                        microChannels = [microChannels, {brainLabel}];
                    end
                end
            end
        end

        config.AdditionalChannels = {};
        channelData = get(channelTable, 'Data');
        for i = 1:size(channelData, 1)
            if ~isempty(channelData{i, 2}) && ~isempty(channelData{i, 3})
                config.AdditionalChannels{end+1} = struct('Label', channelData{i, 2}, 'NumberOfElectrodes', str2double(channelData{i, 3}));
            end
        end

        % Save the montage information to a JSON file
        jsonText = jsonencode(config, 'PrettyPrint', true);
        fid = fopen(montageFileNameStr, 'w');
        if fid == -1
            errordlg('Error saving the file', 'File Error');
        else
            fwrite(fid, jsonText, 'char');
            fclose(fid);
            disp(['Configuration saved to ', montageFileNameStr]);
        end

        % Save the configuration to .cfg file for neuralynx:
        configFileNameStr = get(configFileName, 'String');
        microsToDuplicateList = [];
        generatePegasusConfigFile(str2double(patientID), ...
            {}, ...
            {}, ...
            microChannels, ...
            microsToDuplicateList, ...
            channelData(:, 2), ...
            configFileNameStr)

         showMessageBox(['Configuration saved to: ', newline, ...
             montageFileNameStr, newline, ...
             configFileNameStr], 'Save Successful', 400, 150);
    end

    function showMessageBox(message, title, width, height)
        % Create a custom dialog box
        d = dialog('Position', [300, 300, width, height], 'Name', title);
    
        % Create a text control to display the message
        uicontrol('Parent', d, ...
                  'Style', 'text', ...
                  'Position', [20, height-140, width-40, height-20], ...
                  'String', message, ...
                  'HorizontalAlignment', 'left', ...
                  'FontSize', 15);
    
        % Create a button to close the dialog
        uicontrol('Parent', d, ...
                  'Position', [width/2-60, 20, 120, 30], ...
                  'String', 'Close', ...
                  'Callback', 'delete(gcf)', ...
                  'FontSize', 17);
    end

    function addRow(~, ~)
        % Add a new row to the table
        data = get(channelTable, 'Data');
        rowToAdd = find(cell2mat(data(:, 1)), 1, 'last' );
        if isempty(rowToAdd) || rowToAdd == size(data, 1)
            data(end + 1, :) = {false, '', ''};
        else
            data = [data(1:rowToAdd,:);
                    {false, '', ''};
                    data(rowToAdd+1:end,:)];
        end
        set(channelTable, 'Data', data);
    end

    function removeRow(~, ~)
        % Remove the selected rows from the table
        data = get(channelTable, 'Data');
        rowsToDelete = cell2mat(data(:, 1));
        if all(rowsToDelete)
            choice = questdlg(sprintf(['This will remove All macro channels.\n' ...
                'Do you want to proceed?']), ...
                'Confirmation', ...
                'Yes', 'No', 'No');
            
            % Handle response
            switch choice
                case 'Yes'
                    data(rowsToDelete, :) = [];
                    set(channelTable, 'Data', data);
                case 'No'
                    return
            end
        else
            data(rowsToDelete, :) = [];
            set(channelTable, 'Data', data);
        end
    end

    function moveUp(~, ~)
        % Move the selected row up
        data = get(channelTable, 'Data');
        data = moveUpRows(data);
        set(channelTable, 'Data', data);
    end

    function moveDown(~, ~)
        % Move the selected row down
        data = get(channelTable, 'Data');
        data = moveUpRows(data(end:-1:1, :));
        set(channelTable, 'Data', data(end:-1:1,:));
    end

    function data = moveUpRows(data)
        selectedRows = cell2mat(data(:, 1));
        
        if all(selectedRows) || all(~selectedRows)
            return
        end
        
        selectedRowsDiff = diff([0, selectedRows(:)', 0]);
        startIdx = find(selectedRowsDiff == 1);
        endIdx = find(selectedRowsDiff == -1) - 1;
        for i = 1:length(startIdx)
            if startIdx(i) == 1
                continue
            end
            temp = data(startIdx(i) - 1, :);
            data((startIdx(i): endIdx(i)) - 1, :) = data(startIdx(i): endIdx(i), :);
            data(endIdx(i), :) = temp;
        end
    end

    function selectAllRows(hObject, ~)
        % Select or deselect all rows based on the select all checkbox
        data = get(channelTable, 'Data');
        if get(hObject, 'Value')
            data(:, 1) = {true};
        else
            data(:, 1) = {false};
        end
        set(channelTable, 'Data', data);
    end

    function keyPressCallback(~, event)
        % Check if Shift key is pressed
        if strcmp(event.Key, 'shift')
            setappdata(f, 'isShiftPressed', true);
        end
    end

    function keyReleaseCallback(~, event)
        % Check if Shift key is released
        if strcmp(event.Key, 'shift')
            setappdata(f, 'isShiftPressed', false);
        end
    end

    function cellSelectionCallback(~, event)
        % Handle cell selection with Shift key functionality
        isShiftPressed = getappdata(f, 'isShiftPressed');
        lastSelectedRow = getappdata(f, 'lastSelectedRow');
        selectedRows = event.Indices(:, 1);
        data = get(channelTable, 'Data');
        
        if isShiftPressed && ~isempty(lastSelectedRow)
            % Determine the range of rows to select
            minRow = min([lastSelectedRow; selectedRows]);
            maxRow = max([lastSelectedRow; selectedRows]);
            
            % Update the selection state for the range of rows
            for i = minRow:maxRow
                data{i, 1} = true;
            end
        else
            % Update the selection state for the newly selected row
            for i = 1:size(data, 1)
                if ismember(i, selectedRows)
                    data{i, 1} = true;
                end
            end
        end
        
        % Update the data and last selected row
        set(channelTable, 'Data', data);
        setappdata(f, 'lastSelectedRow', selectedRows(end));
    end

    function updateChannelData(hObject, eventdata)
        % Update the UserData property to track the selected row
        row = eventdata.Indices(1);
        col = eventdata.Indices(2);
        data = get(channelTable, 'Data');
        data{row, col} = eventdata.NewData;
        set(channelTable, 'Data', data);
    end
end
