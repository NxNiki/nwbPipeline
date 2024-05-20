function createCustomUI()

    numMontageAdded = 0;
    % Create the main UI figure
    fig = uifigure('Name', 'Custom Montage Info Tool', 'Position', [100, 100, 900, 700]);  % Increased size

    % Directory and Pattern Input
    lblDir = uilabel(fig, 'Text', 'Directory:', 'Position', [20, 650, 60, 22]);
    editDir = uieditfield(fig, 'text', 'Position', [90, 650, 200, 22], 'Value', '/Volumes/DATA/NLData');
    
    btnSelectFolder = uibutton(fig, 'push', 'Text', 'Select Folder', 'Position', [300, 650, 100, 22], ...
                                'ButtonPushedFcn', @(btn,event) selectFolderButtonPushed());

    lblPattern = uilabel(fig, 'Text', 'Regex Pattern:', 'Position', [410, 650, 90, 22]);
    editPattern = uieditfield(fig, 'text', 'Position', [510, 650, 150, 22], 'Value', '*.ncs');  % Widened text field
    btnAddFiles = uibutton(fig, 'push', 'Text', 'Add Files', 'Position', [670, 650, 100, 22], ...
                            'ButtonPushedFcn', @(btn,event) addFilesButtonPushed());

    % Montage Info Panel - Enlarged and adjusted
    panelMontageInfo = uipanel(fig, 'Title', 'Montage Info', 'Position', [20, 250, 860, 390]);  % Enlarged
    lstFileList = uilistbox(panelMontageInfo, 'Position', [10, 10, 500, 360], 'Items', {});  % Enlarged

    % Dropdown for Brain Areas
    lblArea = uilabel(panelMontageInfo, 'Text', 'Brain Area:', 'Position', [520, 330, 100, 22]);
    ddBrainArea = uidropdown(panelMontageInfo, 'Items', ...
        {'RA', 'LA', 'RAI', 'LAI', 'ROF', 'LOF', 'LAC', 'RAC', 'LPHG', 'RPHG', 'LAH', 'RAH', 'Skip Channels'}, ...
        'Position', [520, 300, 150, 22]);
    lblNumber = uilabel(panelMontageInfo, 'Text', 'Number:', 'Position', [520, 270, 100, 22]);
    editNumber = uieditfield(panelMontageInfo, 'numeric', 'Position', [520, 240, 150, 22]);
    btnAddMontage = uibutton(panelMontageInfo, 'push', 'Text', 'Add Montage', 'Position', [520, 200, 150, 30], ...
                              'ButtonPushedFcn', @(btn,event) addMontageButtonPushed());

    % Output File Panel - Adjusted
    panelOutput = uipanel(fig, 'Title', 'Output File', 'Position', [20, 20, 860, 220]);  % Adjusted
    editOutputJSON = uieditfield(panelOutput, 'text', 'Value', 'montageInfo_patient-xx_exp-xx.json', 'Position', [10, 180, 300, 22]);
    editOutputCSV = uieditfield(panelOutput, 'text', 'Value', 'montageInfo_patient-xx_exp-xx.csv', 'Position', [10, 150, 300, 22]);
    btnLoad = uibutton(panelOutput, 'push', 'Text', 'Load', 'Position', [320, 180, 100, 22]);
    btnConfirm = uibutton(panelOutput, 'push', 'Text', 'Confirm', 'Position', [320, 150, 100, 22]);

    % Define button callbacks
    function addFilesButtonPushed()
        updateFileList();
    end

    function updateFileList()
        folderPath = editDir.Value;
        regexPattern = editPattern.Value;
        if isempty(folderPath) || isempty(regexPattern)
            uialert(fig, 'Directory or Regex Pattern cannot be empty.', 'Input Error');
            return;
        end
        fileList = dir(fullfile(folderPath, regexPattern));
        if isempty(fileList)
            lstFileList.Items = {};
            uialert(fig, 'No files found with the given patterns.', 'File Search');
        else
            lstFileList.Items = [{fileList.name}', repmat({''}, length(fileList), 1)];
        end
    end

    function addMontageButtonPushed()
        selectedArea = ddBrainArea.Value;
        montageNumber = editNumber.Value;
        newItem = cellfun(@(x)sprintf('%s - %d', selectedArea,x),  mat2cell(1: montageNumber));
        startIdx = numMontageAdded + 1;
        endIdx = startIdx + length(newItem) - 1;
        if ~isempty(lstFileList.Items)
            lstFileList.Items(startIdx: endIdx, 2) = newItem;
        end
    end

    function selectFolderButtonPushed()
        folderPath = uigetdir('/Volumes/DATA/NLData', 'Select Folder');
        if folderPath ~= 0
            editDir.Value = folderPath;
            updateFileList(); % Automatically update the file list after selecting a folder
        end
    end
end
