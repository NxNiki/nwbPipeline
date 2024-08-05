% create test data.

scriptDir = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(scriptDir));

inputFiles = {
    '/Volumes/DATA/NLData/D571/EXP2_Screening/2024-07-17_12-09-45/GA1-RAH1.ncs';
    '/Volumes/DATA/NLData/D571/EXP2_Screening/2024-07-17_12-09-45/GA2-RAC4.ncs';
    '/Volumes/DATA/NLData/D571/EXP2_Screening/2024-07-17_12-09-45/GA4-ROF2.ncs';
    '/Volumes/DATA/NLData/D571/EXP2_Screening/2024-07-17_12-09-45/Events.nev'
    };
outputPath = [scriptDir, '/test/neuralynx/raw'];
numBlocks = 100; % each block contains 512 samples.

if ~exist(outputPath, "dir")
    mkdir(outputPath);
end

for i = 1: length(inputFiles)

    [~, ~, fileExtension] = fileparts(inputFiles{i});
    if fileExtension == ".ncs"
        [timeStamps, channelNumber, sampleFrequency, numSamples, signal, header] = Nlx2MatCSC_v3(inputFiles{i},[1,1,1,1,1],1,1);
        Mat2NlxCSC( ...
                    fullfile(outputPath, sprintf('CSC_%d.ncs', i)), ...
                    0, 1, 1, numBlocks, [1 1 1 1 1 1], ...
                    timeStamps(1:numBlocks), ...
                    channelNumber(1:numBlocks), ...
                    sampleFrequency(1:numBlocks), ...
                    numSamples(1:numBlocks), ...
                    signal(:, 1:numBlocks), ...
                    header);

    elseif fileExtension == ".nev"
        % so far we don't know how to cut .nev files to just copy it:
        copyfile(inputFiles{i}, fullfile(outputPath, 'Events.nev'));
    end
end
