%the struct runData holds data about patients and where the different event
%types are stored
clear
% ---- UPDATE this part -

% the main path for extracted data here -
% for the given example, it's in the same folder as this code:

base_path = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/566_MovieParadigm/Experiment-8/';
data_p_path = fullfile(base_path, 'CSC_macro');
outputFolder = fullfile(base_path, 'Spindles');

if ~exist(outputFolder, "dir")
    mkdir(outputFolder);
end

sleepScoringFileName = fullfile(base_path, 'sleep_score/sleepScore_ROF2_001.mat');

[macroFiles, macroTimestampFiles] = readCSCFilePath(data_p_path);

channel_index = 69;


%% an example for detecting spindles directly using SpindleDetectorClass (it's the same thing the wrapper below does in batch)


%loading - sleep scoring, IIS, data
sleepScoring = load(sleepScoringFileName);
sleepScoring = sleepScoring.sleep_score_vec;
sleepScoring = [];

%% load or perform interictal Spikes Detection

peakTimes = [];
channelName = extractChannelName(macroFiles{channel_index, 1});
currData = combineCSC(macroFiles(channel_index, :), macroTimestampFiles);

%% detect the spindles
returnStats = 1;
sd = SpindleDetectorClass;
sd.spindleRangeMin = 11;
sd.samplingRate = 2000;
[spindlesTimes,spindleStats,spindlesStartEndTimes] = sd.detectSpindles(currData, sleepScoring, peakTimes, returnStats);

matObj = matfile(fullfile(outputFolder, sprintf('spindles_%s.mat', channelName)), "Writable", true);
matObj.spindlesTimes = spindlesTimes;
matObj.spindleStats = spindleStats;
matObj.spindlesStartEndTimes = spindlesStartEndTimes;

%plotting the single spindles and saving the figures
sd.plotSpindlesSimple(currData, spindlesTimes, outputFolder)

% scroll through spindles and their spectrograms using any key
blockSize = 4;
% sd.plotSpindles(currData,spindlesTimes,blockSize);



