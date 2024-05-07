clear

patient = 573;
exp = 13;

trialFolder = sprintf('/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/Screening/%d_Screening/Experiment%d/CSC_data', patient, exp);

addpath(genpath('/Users/XinNiuAdmin/Documents/MATLAB/DataPipeline_Screening'));
rmpath(genpath('/Users/XinNiuAdmin/Documents/MATLAB/DataPipeline_Screening/Utilities/chronux'));

%% unpack data (only for Iowa data):

dataFolder='/Volumes/DATA/NLData/i720R/720-098_UCLA_Screening1/2024-04-29_14-41-45';

if ~exist(trialFolder, "dir")
    mkdir(trialFolder)
end

computeTS = 1;
[data, timeStamps, samplingInterval, chNum] = Nlx_readCSC(fullfile(dataFolder, ['PDes' num2str(1) '.ncs']), computeTS);
time0 = timeStamps(1); 
timeend = timeStamps(end);

save_aux(1, data, time0, timeend, samplingInterval, trialFolder);
save(fullfile(trialFolder, 'lfpTimeStamps.mat'), 'time0', 'timeend', 'timeStamps', 'samplingInterval'); 

start = 97;
endIdx = 112;
computeTS = 0;

parfor i=start: endIdx
    fprintf(['processing file: %d, ' fullfile(dataFolder, ['PDes' num2str(i) '.ncs']), '\n'], i);
    %if ~exist(['CSC' num2str(i) '.mat'], 'file')

    [data, ~, samplingInterval, chNum] = Nlx_readCSC(fullfile(dataFolder, ['PDes' num2str(i) '.ncs']), computeTS);
    data = data';
    save_aux(i, data, time0, timeend, samplingInterval, trialFolder);
 %   end
end

disp('unpacking finished!')

%%

automaticScreeningAnalyze5(trialFolder);

%%
% use PDM to add patient and session before proceeding with the following
% steps:

imageDirectory = sprintf('/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/Screening/%d_Screening/Experiment%d/trial1', patient, exp);

updateChannelMetaData(patient, exp)
% [clusterCharacteristics] = calculateClusterCharacteristics(patient, exp, 1, trialFolder);
[clusterCharacteristics] = calculateClusterCharacteristics_video(patient, exp, 1, imageDirectory);

%%

command = ['chmod -R 775 ', trialFolder];
system(command)

patientInfoFolder = ' /Users/XinNiuAdmin/HoffmanMount/data/PATIENT_DATABASE/Patient1720';
command = ['chmod -R 775 ', patientInfoFolder];
system(command)

%%

rasters_by_unit(patient, exp, imageDirectory, 1, 0)
rasters_by_unit(patient, exp, imageDirectory, 0, 0)

rasters_by_image(patient, exp, imageDirectory, 0);

%%

% rasters_by_unit_video(patient, exp, imageDirectory, 1, 0)
rasters_by_unit_video(patient, exp, imageDirectory, 0, 0)
rasters_by_image(patient, exp, imageDirectory, 0);



function save_aux(i, data, time0, timeend, samplingInterval, outputDir)
    save(fullfile(outputDir, ['CSC' num2str(i) '.mat']), 'data', 'time0', 'timeend', 'samplingInterval');
end

