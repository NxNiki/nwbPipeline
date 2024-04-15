% unpack the macro neuralynx data.
% this script should run with Matlab 2023a or earlier if on Mac with apple
% silicon.


expId = 1;
filePath = '/Users/XinNiuAdmin/Documents/NWBTest/inputNLX/P384/EXP1_Hagar_Movie';
outFilePath = '/Users/XinNiuAdmin/Documents/NWBTest/output/Screening/P384_Hagar_Movie';

% 0: will remove all previous unpack files.
% 1: skip existing files.
skipExist = 1; 

expOutFilePath = [outFilePath, sprintf('/Experiment%d/', expId)];

%% unpack micro files:

microOutFilePath = [outFilePath, sprintf('/Experiment%d/CSC_micro/', expId)];

if ~exist(microOutFilePath, "dir")
    mkdir(microOutFilePath);
end

inMicroFiles = {fullfile(filePath, 'CSC4.Ncs')};
outMicroFiles = {'CSC4.mat'};

tic
unpackData(inMicroFiles, outMicroFiles, microOutFilePath, 1, skipExist);
toc
disp('micro files unpack finished!')





