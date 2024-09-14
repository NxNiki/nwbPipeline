% create test data.

scriptDir = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(scriptDir));


outputPath = [scriptDir, '/test/mat73'];

if ~exist(outputPath, "dir")
    mkdir(outputPath);
end

m = matfile(fullfile(outputPath, 'mat73.mat'));
m.data = rand(1, 1000);
