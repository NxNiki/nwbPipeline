% sleep stage detection with macro iEEG data:
% adapted from Maya's work: https://github.com/mgevasagiv/sleepScoringIEEG
% Xin Niu.
close all;

% macroPath = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/576_MovieParadigm/Experiment-16/CSC_macro';
macroPath = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/570_MovieParadigm/Experiment-5/CSC_macro';
[macroFiles, macroTimestampFiles] = readCSCFilePath(macroPath);
skipExist = 1;

%% Step 1 - create hypnograms for all channels
disp('sleep hypnogram...')
tic
outputPath = fullfile(fileparts(macroPath), 'hypnogram');
create_sleepHypnogram_per_pt(macroFiles, macroTimestampFiles, outputPath, skipExist)
toc
disp('sleep hypnogram finished!')

%% Step 2 - review hypnograms, choose one channel for sleep scoring.

channel_index = [1];

%% Step 3 - run automated sleep scoring on the selected channels

manualValidation = 0;
outputPath = fullfile(fileparts(macroPath), 'sleep_score');
disp('automated sleep scoring...')
tic
sleepScoring_iEEG_wrapper(macroFiles(channel_index, :), macroTimestampFiles, outputPath, manualValidation); 
toc
disp('automated sleep scoring finished!')

%% Step 3 - run automated sleep scoring on the selected channels

manualValidation = 1;
disp('manual sleep scoring...')
tic
sleepScoring_iEEG_wrapper(macroFiles(channel_index, :), macroTimestampFiles, outputPath, manualValidation); 
toc
disp('manual sleep scoring finished!')