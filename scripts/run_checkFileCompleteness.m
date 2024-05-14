% check completeness of unpacked .mat files

% filePath = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/568_MovieParadigm/Experiment*/CSC_micro';
% filePath = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/567_MovieParadigm/Experiment*/CSC_micro';
% filePath = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/566_MovieParadigm/Experiment*/CSC_micro';
% filePath = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/565_MovieParadigm/Experiment*/CSC_micro';
filePath = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/563_MovieParadigm/Experiment*/CSC_micro';
% filePath = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/562_MovieParadigm/Experiment*/CSC_micro';


fileNames = dir([filePath, '/*.mat']);
fileNames = fullfile({fileNames.folder}, {fileNames.name});

deletedFiles = [];

for i = 1:length(fileNames)
    % Specify the filename of your MAT-file
    filename = fileNames{i};
    
    % Specify the variable name you are checking for
    varName = 'timeend';
    
    % Load the information about variables in the MAT-file
    variablesInfo = whos('-file', filename);
    
    % Check if the variable exists in the file
    if ~ismember(varName, {variablesInfo.name})
        disp(['incomplete file is deleted:' filename]);
        delete(filename);
        deletedFiles = [deletedFiles, {filename}];
    end

end

writecell(deletedFiles', 'deletedFiles563.csv');