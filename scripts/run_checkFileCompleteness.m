% when unpack got interrupted by connection error, some files may not be
% complete. this script checks if timeend is a the unpacked file, otherwise
% the file is incomplete and should be re-unpacked. This is not necessary
% as in the recent update, we use a temp file to save incomplete data.

% check completeness of unpacked .mat files
% hidden .mat file and incomplete files will be deleted.


% filePath = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/568_MovieParadigm/Experiment*/CSC_micro';
% filePath = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/567_MovieParadigm/Experiment*/CSC_micro';
% filePath = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/566_MovieParadigm/Experiment*/CSC_micro';
% filePath = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/565_MovieParadigm/Experiment*/CSC_micro';
% filePath = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/563_MovieParadigm/Experiment*/CSC_micro';
% filePath = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/562_MovieParadigm/Experiment*/CSC_micro';
% filePath = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/572_MovieParadigm/Experiment*/CSC_micro';
filePath = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/573_MovieParadigm/Experiment*/CSC_micro';

logFileName = 'deletedFiles573.csv';

%%
hiddenFiles = dir([filePath, '/.*.mat']);

% Loop through the hidden mat files and delete each one
for k = 1:length(hiddenFiles)
    % Construct the full path to the file
    file_path = fullfile(hiddenFiles(k).folder, hiddenFiles(k).name);
    fprintf('remove hidden file:\n %s\n', file_path);
    % Delete the file
    delete(file_path);
end

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

if ~isempty(deletedFiles)
    writecell(deletedFiles', logFileName);
end