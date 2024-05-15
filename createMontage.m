function createMontage()
    % Create the main figure
    fig = uifigure('Name', 'Channel Montage GUI', 'Position', [100, 100, 600, 400]);

    % Add panels
    inputPanel = uipanel(fig, 'Title', 'Input Path', 'Position', [10, 330, 280, 60]);
    outputPanel = uipanel(fig, 'Title', 'Output Path', 'Position', [300, 330, 280, 60]);
    montagePanel = uipanel(fig, 'Title', 'Montage', 'Position', [10, 120, 580, 200]);
    savePanel = uipanel(fig, 'Title', 'Save Results', 'Position', [10, 60, 580, 50]);
    loadSavePanel = uipanel(fig, 'Position', [10, 10, 580, 40]);

    % Populate each panel
    add_input_path_controls(inputPanel);
    add_output_path_controls(outputPanel);
    add_montage_controls(montagePanel);
    add_save_controls(savePanel);
    add_load_save_controls(loadSavePanel);
end
