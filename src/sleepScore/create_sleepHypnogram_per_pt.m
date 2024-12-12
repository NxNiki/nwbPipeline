function create_sleepHypnogram_per_pt(macroPath, skipExist)

if ~exist('skipExist','var')
    skipExist = 0;
end

outputPath = fullfile(fileparts(macroPath), 'hypnogram');
if ~exist(outputPath, "dir")
    mkdir(outputPath);
end

[macroFiles, macroTimestampFiles] = readFilePath([], macroPath, 'macro');

% Basic statistics of sleep oscillations
% Whole sleep spectrogram - to see SWS\Spindles periods
% Generating spectrograms for *all* channels
  
for i = 1:length(macroFiles)
    figureName = fullfile(outputPath, strrep(macroFiles{i}, '.mat', '.png'));
    if exist(figureName, "file") && skipExist
        continue;
    end

    fprintf('process: %s\n', macroFiles{i});

    macroFile = matfile(fullfile(macroPath, macroFiles{i}));
    data = single(macroFile.data) * macroFile.ADBitVolts;

    plotHypnogram_perChannel(data, 2000, figureName)
    % PrintActiveFigs(outputPath);
end

