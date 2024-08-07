% test unpack neuralynx data
% use 


scriptDir = fileparts(mfilename('fullpath'));
addpath(genpath(fileparts(scriptDir)));

%% unpack micro files:
ncsFiles = {
    fullfile(scriptDir, 'neuralynx/raw/CSC_1.ncs')
    fullfile(scriptDir, 'neuralynx/raw/CSC_2.ncs')
    fullfile(scriptDir, 'neuralynx/raw/CSC_3.ncs')
    };

outFiles = {
    'GA1-RA1_001.mat'
    'GB2-RAH1_001.mat'
    'GD4-LEC1_001.mat'
    };

outFiles = unpackData(ncsFiles, outFiles, fullfile(scriptDir, 'neuralynx/CSC_micro'), 1, 0);
writecell(ncsFiles, fullfile(scriptDir, 'neuralynx/CSC_micro/inFileNames.csv'));
writecell(outFiles, fullfile(scriptDir, 'neuralynx/CSC_micro/outFileNames.csv'));


%% unpack macro files:
ncsFiles = {
    fullfile(scriptDir, 'neuralynx/raw/CSC_1.ncs')
    fullfile(scriptDir, 'neuralynx/raw/CSC_2.ncs')
    fullfile(scriptDir, 'neuralynx/raw/CSC_3.ncs')
    };

outFiles = {
    'GA1-RA1_001.mat'
    'GB2-RAH1_001.mat'
    'GD4-LEC1_001.mat'
    };

outFiles = unpackData(ncsFiles, outFiles, fullfile(scriptDir, 'neuralynx/CSC_macro'), 1, 0);
writecell(ncsFiles, fullfile(scriptDir, 'neuralynx/CSC_macro/inFileNames.csv'));
writecell(outFiles, fullfile(scriptDir, 'neuralynx/CSC_macro/outFileNames.csv'));