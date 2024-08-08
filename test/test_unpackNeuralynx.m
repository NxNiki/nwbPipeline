% test unpack neuralynx data
% use 


scriptDir = fileparts(mfilename('fullpath'));
addpath(genpath(fileparts(scriptDir)));

%% unpack micro files:
ncsFiles = {
    fullfile(scriptDir, 'neuralynx/raw/GA1-RAH1.ncs')
    fullfile(scriptDir, 'neuralynx/raw/GA2-RAC4.ncs')
    fullfile(scriptDir, 'neuralynx/raw/GA4-ROF2.ncs')

    };

outFiles = {
    'GA1-RAH1_001.mat' % ensure spike sort can handle suffix.
    'GA2-RAC4.mat'
    'GA4-ROF2.mat'

    };

outFiles = unpackData(ncsFiles, outFiles, fullfile(scriptDir, 'neuralynx/CSC_micro'), 1, 0);
writecell(ncsFiles, fullfile(scriptDir, 'neuralynx/CSC_micro/inFileNames.csv'));
writecell(outFiles, fullfile(scriptDir, 'neuralynx/CSC_micro/outFileNames.csv'));


%% unpack macro files:
ncsFiles = {
    fullfile(scriptDir, 'neuralynx/raw/RAH1.ncs')
    fullfile(scriptDir, 'neuralynx/raw/RAC4.ncs')
    fullfile(scriptDir, 'neuralynx/raw/ROF2.ncs')
    };

outFiles = {
    'RAH1.mat'
    'RAC4.mat'
    'ROF2.mat'
    };

outFiles = unpackData(ncsFiles, outFiles, fullfile(scriptDir, 'neuralynx/CSC_macro'), 1, 0);
writecell(ncsFiles, fullfile(scriptDir, 'neuralynx/CSC_macro/inFileNames.csv'));
writecell(outFiles, fullfile(scriptDir, 'neuralynx/CSC_macro/outFileNames.csv'));