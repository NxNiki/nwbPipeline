function create_sleepHypnogram_per_pt(macroPath, skipExist)

if ~exist('skipExist','var')
    skipExist = 1;
end

outputPath = fullfile(fileparts(macroPath), 'hypnogram');
if ~exist(outputPath, "dir")
    mkdir(outputPath);
end

[macroFiles, macroTimestampFiles] = readCSCFilePath(macroPath);

% Basic statistics of sleep oscillations
% Whole sleep spectrogram - to see SWS\Spindles periods
% Generating spectrograms for *all* channels
  
parfor i = 1:size(macroFiles, 1)
    
    [~, fname] = fileparts(macroFiles{i, 1});
    figureName = fullfile(outputPath, [fname, '.png']);
    if exist(figureName, "file") && skipExist
        continue;
    end

    data = combineCSC(macroFiles(i, :), macroTimestampFiles);
    plotHypnogram_perChannel(data, 2000, figureName)
    fprintf('done.\n');
    % PrintActiveFigs(outputPath);

end

