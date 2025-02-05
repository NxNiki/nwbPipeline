%the struct runData holds data about patients and where the different event
%types are stored
clear
% ---- UPDATE this part -

% the main path for extracted data here -
% for the given example, it's in the same folder as this code:

base_path = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/566_MovieParadigm/Experiment-8/';
data_p_path = fullfile(base_path, 'CSC_macro');
sleepScoringFileName = fullfile(base_path, 'sleep_score/sleepScore_ROF2_001.mat');

[macroFiles, macroTimestampFiles] = readCSCFilePath(data_p_path);

channel_index = 69;


%% an example for detecting spindles directly using SpindleDetectorClass (it's the same thing the wrapper below does in batch)
sd = SpindleDetectorClass;

%loading - sleep scoring, IIS, data
sleepScoring = load(sleepScoringFileName);
sleepScoring = sleepScoring.sleep_score_vec;

%% load or perform interictal Spikes Detection

peakTimes = [];
currData = combineCSC(macroFiles(channel_index, :), macroTimestampFiles);

%detecting the spindles
returnStats = 1;
sd.spindleRangeMin = 11;
[spindlesTimes,spindleStats,spindlesStartEndTimes] = sd.detectSpindles(currData, sleepScoring, peakTimes, returnStats);

%plotting the single spindles and saving the figures
sd.plotSpindlesSimple(currData, spindlesTimes, outputFolder)

% scroll through spindles and their spectrograms using any key
blockSize = 4;
sd.plotSpindles(currData,spindlesTimes,blockSize);



