function setMontageUI()
    % Create the main UI figure
    fig = uifigure('Name', 'Custom Montage Info Tool', 'Position', [100, 100, 800, 600]);

    % Directory and Pattern Input
    lblDir = uilabel(fig, 'Text', 'Directory:', 'Position', [20, 560, 60, 22]);
    editDir = uieditfield(fig, 'text', 'Position', [90, 560, 200, 22], 'Value', '/Volumes/DATA/NLData');
    
    btnSelectFolder = uibutton(fig, 'push', 'Text', 'Select Folder', 'Position', [300, 560, 100, 22], ...
                                'ButtonPushedFcn', @(btn,event) selectFolderButtonPushed());

    lblPattern = uilabel(fig, 'Text', 'Regex Pattern:', 'Position', [410, 560, 90, 22]);
    editPattern = uieditfield(fig, 'text', 'Position', [510, 560, 100, 22]);
    btnAddFiles = uibutton(fig, 'push', 'Text', 'Add Files', 'Position', [620, 560, 100, 22], ...
                            'ButtonPushedFcn', @(btn,event) addFilesButtonPushed());

    % Montage Info Panel
    panelMontageInfo = uipanel(fig, 'Title', 'Montage Info', 'Position', [20, 320, 760, 230]);
    lstFileList = uilistbox(panelMontageInfo, 'Position', [10, 10, 350, 200], 'Items', {});

    % Dropdown for Brain Areas
    lblArea = uilabel(panelMontageInfo, 'Text', 'Brain Area:', 'Position', [370, 180, 100, 22]);
    ddBrainArea = uidropdown(panelMontageInfo, 'Items', ...
        {'RA', 'LA', 'RAI', 'LAI', 'ROF', 'LOF', 'LAC', 'RAC', 'LPHG', 'RPHG', 'LAH', 'RAH', 'Skip Channels'}, ...
        'Position', [370, 150, 150, 22]);
    lblNumber = uilabel(panelMontageInfo, 'Text', 'Number:', 'Position', [370, 120, 100, 22]);
    editNumber = uieditfield(panelMontageInfo, 'numeric', 'Position', [370, 90, 150, 22]);
    btnAddMontage = uibutton(panelMontageInfo, 'push', 'Text', 'Add Montage', 'Position', [370, 50, 150, 30], ...
                              'ButtonPushedFcn', @(btn,event) addMontageButtonPushed());

    % Output File Panel
    panelOutput = uipanel(fig, 'Title', 'Output File', 'Position', [20, 20, 760, 290]);
    editOutputJSON = uieditfield(panelOutput, 'text', 'Value', 'montageInfo_patient-xx_exp-xx.json', 'Position', [10, 220, 300, 22]);
    editOutputCSV = uieditfield(panelOutput, 'text', 'Value', 'montageInfo_patient-xx_exp-xx.csv', 'Position', [10, 190, 300, 22]);
    btnLoad = uibutton(panelOutput, 'push', 'Text', 'Load', 'Position', [320, 220, 100, 22]);
    btnConfirm = uibutton(panelOutput, 'push', 'Text', 'Confirm', 'Position', [320, 190, 100, 22]);

    % Define button callbacks
    function addFilesButtonPushed()
        folderPath = editDir.Value;
        regexPatterns = strsplit(editPattern.Value, ',');
        fileList = [];
        for i = 1:length(regexPatterns)
            tempFiles = dir(fullfile(folderPath, strtrim(regexPatterns{i}))); % Trim whitespace
            fileList = [fileList; tempFiles]; % Accumulate files from all patterns
        end
        if isempty(fileList)
            lstFileList.Items = {};
            uialert(fig, 'No files found with the given patterns.', 'File Search');
        else
            lstFileList.Items = {fileList.name};
        end
    end

    function addMontageButtonPushed()
        selectedArea = ddBrainArea.Value;
        montageNumber = editNumber.Value;
        newItem = sprintf('%s - %d', selectedArea, montageNumber);
        if isempty(lstFileList.Items)
            lstFileList.Items = {newItem};
        else
            lstFileList.Items = [lstFileList.Items; {newItem}];
        end
    end

    function selectFolderButtonPushed()
        folderPath = uigetdir('/Volumes/DATA/NLData', 'Select Folder');
        if folderPath ~= 0
            editDir.Value = folderPath;
        end
    end
end
