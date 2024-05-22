function MontageConfigUI()
    % Create a figure for the UI
    f = figure('Position', [100, 100, 1000, 900], 'Name', 'Experiment Setup');

    % Experiment Info Panel
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

    % Montage Panel
    montagePanel = uipanel('Parent', f, 'Title', 'Montage', ...
                           'Position', [0.05, 0.125, 0.7, 0.77], 'FontSize', 12);

    % Brain labels
    brainLabels = {'RA', 'LA', 'RAI', 'LAI', 'ROF', 'LOF', 'RAC', 'LAC', 'RPHG', 'LPHG', 'RAH', 'LAH', 'RLSA', 'RLSS', 'RLSP'};
    customBrainLabel = 'Custom';

    % Default pack labels
    defaultPackLabels = {'GA', 'GB', 'GC', 'GD'};

    % Create packs and ports
    numPacks = 4;
    numPortsPerPack = 4;
    packHandles = cell(numPacks, numPortsPerPack, 4); % Handles for macros, micros, brain labels, and pack label
    defaultNumChannelsMacro = '7';
    defaultNumChannelsMicro = '8';

    for packIdx = 1:numPacks
        row = floor((packIdx - 1) / 2);
        col = mod(packIdx - 1, 2);
        packPanel = uipanel('Parent', montagePanel, 'Title', ['Pack ' num2str(packIdx)], ...
                            'Units', 'normalized', 'Position', [0.025 + 0.475 * col, 0.5 - 0.5 * row, 0.45, 0.5], 'FontSize', 12);

        % Pack label
        uicontrol('Parent', packPanel, 'Style', 'text', 'String', 'Pack Label:', ...
                  'Units', 'normalized', 'Position', [0.01, 0.85, 0.2, 0.1], 'HorizontalAlignment', 'left', 'FontSize', 12);
        packLabelEdit = uicontrol('Parent', packPanel, 'Style', 'edit', 'String', defaultPackLabels{packIdx}, ...
                                  'Units', 'normalized', 'Position', [0.22, 0.85, 0.3, 0.1], 'FontSize', 12);
        % Pack checkbox
        packCheckbox = uicontrol('Parent', packPanel, 'Style', 'checkbox', 'Value', 1, ...
                                 'Units', 'normalized', 'Position', [0.55, 0.85, 0.4, 0.1], 'String', 'Enable Pack', 'FontSize', 12, ...
                                 'Callback', @(src, event)togglePackFields(packIdx, src));

        packHandles{packIdx, numPortsPerPack + 1, 4} = packLabelEdit; % Store pack label handle
        packHandles{packIdx, numPortsPerPack + 1, 5} = packCheckbox;

        for portIdx = 1:numPortsPerPack
            % Port label
            uicontrol('Parent', packPanel, 'Style', 'text', 'String', ['Port ' num2str(portIdx)], ...
                      'Units', 'normalized', 'Position', [0.01, 0.71 - 0.2 * (portIdx - 1), 0.2, 0.08], 'HorizontalAlignment', 'left', 'FontSize', 12);
            % Number of Macros
            uicontrol('Parent', packPanel, 'Style', 'text', 'String', 'Macros:', ...
                      'Units', 'normalized', 'Position', [0.22, 0.61 - 0.2 * (portIdx - 1), 0.2, 0.08], 'HorizontalAlignment', 'left', 'FontSize', 12);
            macrosEdit = uicontrol('Parent', packPanel, 'Style', 'edit', 'String', defaultNumChannelsMacro, ...
                                   'Units', 'normalized', 'Position', [0.36, 0.63 - 0.2 * (portIdx - 1), 0.1, 0.07], 'FontSize', 12, ...
                                   'Callback', @validateNumChannels);
            % Number of Micros
            uicontrol('Parent', packPanel, 'Style', 'text', 'String', 'Micros:', ...
                      'Units', 'normalized', 'Position', [0.47, 0.61 - 0.2 * (portIdx - 1), 0.2, 0.08], 'HorizontalAlignment', 'left', 'FontSize', 12);
            microsEdit = uicontrol('Parent', packPanel, 'Style', 'edit', 'String', defaultNumChannelsMicro, ...
                                   'Units', 'normalized', 'Position', [0.6, 0.63 - 0.2 * (portIdx - 1), 0.1, 0.07], 'FontSize', 12, ...
                                   'Callback', @validateNumChannels);
            % Brain label
            brainLabelPopup = uicontrol('Parent', packPanel, 'Style', 'popupmenu', 'String', [brainLabels, {customBrainLabel}], ...
                                        'Units', 'normalized', 'Position', [0.22, 0.69 - 0.2 * (portIdx - 1), 0.5, 0.1], 'FontSize', 12);

            packHandles{packIdx, portIdx, 1} = macrosEdit;
            packHandles{packIdx, portIdx, 2} = microsEdit;
            packHandles{packIdx, portIdx, 3} = brainLabelPopup;
        end
    end

    % misc Macro Channels Panel
    channelPanel = uipanel('Parent', f, 'Title', 'misc Macro Channels', ...
                           'Position', [0.75, 0.125, 0.2, 0.77], 'FontSize', 12);

    % Additional channels
    miscMacros = {'C3', 'C4', 'PZ', 'Ez', 'EOG1', 'EOG2', 'EMG1', 'EMG2', 'A1', 'A2', ...
                          'MICROPHONE', 'HR_Ref', 'HR', 'TTLRef', 'TTLSync', 'Analogue1', 'Analogue2'};

    % Select/Deselect all
    uicontrol('Parent', channelPanel, 'Style', 'checkbox', 'String', 'Select/Deselect All', ...
              'Units', 'normalized', 'Position', [0.05, 0.95, 0.9, 0.05], 'Callback', @toggleSelectAllChannels, 'FontSize', 12);

    miscMacroChannelHandles = cell(length(miscMacros), 2); % Handles for labels and checkboxes

    for i = 1:length(miscMacros)
        labelEdit = uicontrol('Parent', channelPanel, 'Style', 'edit', 'String', miscMacros{i}, ...
                              'Units', 'normalized', 'Position', [0.05, 0.95 - 0.05 * (i + 1), 0.7, 0.05], 'FontSize', 12);
        checkbox = uicontrol('Parent', channelPanel, 'Style', 'checkbox', ...
                             'Units', 'normalized', 'Position', [0.8, 0.95 - 0.05 * (i + 1), 0.2, 0.05], 'FontSize', 12);

        miscMacroChannelHandles{i, 1} = labelEdit;
        miscMacroChannelHandles{i, 2} = checkbox;
    end

    % Save Config Panel
    saveConfigPanel = uipanel('Parent', f, 'Title', 'Save Config', ...
                              'Position', [0.05, 0.04, 0.9, 0.08], 'FontSize', 12);

    % File name inputs
    montageFileName = uicontrol('Parent', saveConfigPanel, 'Style', 'edit', ...
                                'String', 'montage_Patient-_exp-.json', ...
                                'Units', 'normalized', 'Position', [0.01, 0.12, 0.38, 0.6], 'FontSize', 12);

    configFileName = uicontrol('Parent', saveConfigPanel, 'Style', 'edit', ...
                               'String', 'config_Patient-_exp-.cfg', ...
                               'Units', 'normalized', 'Position', [0.4, 0.12, 0.4, 0.6], 'FontSize', 12);

    % Load and Confirm buttons
    uicontrol('Parent', saveConfigPanel, 'Style', 'pushbutton', 'String', 'Load', ...
              'Units', 'normalized', 'Position', [0.82, 0.1, 0.08, 0.8], 'Callback', @loadConfigFile, 'FontSize', 12);
    uicontrol('Parent', saveConfigPanel, 'Style', 'pushbutton', 'String', 'Confirm', ...
              'Units', 'normalized', 'Position', [0.91, 0.1, 0.08, 0.8], 'Callback', @saveConfig, 'FontSize', 12);

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

    function toggleSelectAllChannels(hObject, ~)
        % Callback to select/deselect all additional channels
        val = get(hObject, 'Value');
        for i = 1:length(miscMacroChannelHandles)
            set(miscMacroChannelHandles{i, 2}, 'Value', val);
        end
    end

    function togglePackFields(packIdx, checkbox)
        % Enable/disable pack fields based on checkbox state
        for portIdx = 1:numPortsPerPack
            if get(checkbox, 'Value') == 1
                set(packHandles{packIdx, portIdx, 1}, 'Enable', 'on');
                set(packHandles{packIdx, portIdx, 2}, 'Enable', 'on');
                set(packHandles{packIdx, portIdx, 3}, 'Enable', 'on');
            else
                set(packHandles{packIdx, portIdx, 1}, 'Enable', 'off');
                set(packHandles{packIdx, portIdx, 2}, 'Enable', 'off');
                set(packHandles{packIdx, portIdx, 3}, 'Enable', 'off');
            end
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

        packs = fieldnames(config.Packs);
        for i = 1:numPacks
            packLabel = packs{i};
            set(packHandles{i, 1, 4}, 'String', packLabel);
            ports = config.Packs.(packLabel);
            portFields = fieldnames(ports);

            if isempty(portFields)
                set(packHandles{i, numPortsPerPack + 1, 5}, 'Value', 0);
                togglePackFields(i, packHandles{i, numPortsPerPack + 1, 5})
                continue
            end

            for j = 1:numPortsPerPack
                portData = ports.(portFields{j});
                set(packHandles{i, j, 1}, 'String', num2str(portData.Macros));
                set(packHandles{i, j, 2}, 'String', num2str(portData.Micros));
                brainLabelIdx = find(strcmp(brainLabels, portData.BrainLabel));
                if isempty(brainLabelIdx)
                    brainLabelIdx = length(brainLabels) + 1; % Custom label
                    set(packHandles{i, j, 3}, 'String', portData.BrainLabel);
                end
                set(packHandles{i, j, 3}, 'Value', brainLabelIdx);
            end
        end

        % Load additional channels
        for i = 1:length(miscMacroChannelHandles)
            set(miscMacroChannelHandles{i, 2}, 'Value', 0); % Deselect all initially
        end

        for i = 1:length(config.AdditionalChannels)
            channel = config.AdditionalChannels{i};
            idx = find(strcmp(miscMacros, channel));
            if ~isempty(idx)
                set(miscMacroChannelHandles{idx, 2}, 'Value', 1); % Select the channel
            end
        end
    end

    function saveConfig(~, ~)
        % Function to save config files
        patientID = get(patientIDEdit, 'String');
        experimentID = get(experimentIDEdit, 'String');
        updateFileNames()
        montageFileNameStr = get(montageFileName, 'String');

        % Create a structure to hold the configuration
        config = struct();
        config.PatientID = patientID;
        config.ExperimentID = experimentID;
        config.Packs = struct();

        macroChannels = {};
        macroChannelsNot7 = {};
        microChannels = {};
        for packIdx = 1:numPacks
            packLabel = get(packHandles{packIdx, numPortsPerPack + 1, 4}, 'String');
            sanitizedPackLabel = matlab.lang.makeValidName(packLabel);  % Sanitize pack label to make it a valid field name
            config.Packs.(sanitizedPackLabel) = struct();

            for portIdx = 1:numPortsPerPack
                if strcmp(get(packHandles{packIdx, portIdx, 1}, 'Enable'), 'on')
                    macros = get(packHandles{packIdx, portIdx, 1}, 'String');
                    micros = get(packHandles{packIdx, portIdx, 2}, 'String');
                    brainLabel = brainLabels{get(packHandles{packIdx, portIdx, 3}, 'Value')};
                    config.Packs.(sanitizedPackLabel).(['Port' num2str(portIdx)]) = struct( ...
                        'Macros', str2double(macros), ...
                        'Micros', str2double(micros), ...
                        'BrainLabel', brainLabel);

                    macroChannels = [macroChannels, {brainLabel}];
                    if str2double(macros) ~= 7
                        macroChannelsNot7 = [macroChannelsNot7, {brainLabel, str2double(macros)}];
                    end
                    if str2double(micros) > 0
                        microChannels = [microChannels, {brainLabel}];
                    end
                end
            end
        end

        config.AdditionalChannels = {};
        for i = 1:length(miscMacroChannelHandles)
            if get(miscMacroChannelHandles{i, 2}, 'Value') == 1
                config.AdditionalChannels{end+1} = get(miscMacroChannelHandles{i, 1}, 'String');
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
            macroChannels, ...
            macroChannelsNot7, ...
            microChannels, ...
            microsToDuplicateList, ...
            config.AdditionalChannels, ...
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

end
