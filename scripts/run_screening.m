clear

patient = 1720;
exp = 1;

trialFolder = sprintf('/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/Screening/%d_Screening/Experiment%d/CSC_data', patient, exp);
imageDirectory = sprintf('/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/Screening/%d_Screening/Experiment%d/Screening_1/trial1', patient, exp);

addpath(genpath('/Users/XinNiuAdmin/Documents/MATLAB/DataPipeline_Screening'));
rmpath(genpath('/Users/XinNiuAdmin/Documents/MATLAB/DataPipeline_Screening/Utilities/chronux'));

%% unpack data:

dataFolder='/Volumes/DATA/NLData/i720R/720-098_UCLA_Screening1/2024-04-29_14-41-45';

if ~exist(trialFolder, "dir")
    mkdir(trialFolder)
end

start = 97;
endIdx = 112;

computeTS = 1;
[data, timeStamps, samplingInterval, chNum] = Nlx_readCSC(fullfile(dataFolder, ['PDes' num2str(start) '.ncs']), computeTS);
time0 = timeStamps(1); 
timeend = timeStamps(end);
computeTS = 0;

parfor i=start + 1: endIdx
    fprintf(['processing file: %d, ' fullfile(dataFolder, ['PDes' num2str(i) '.ncs']), '\n'], i);
    %if ~exist(['CSC' num2str(i) '.mat'], 'file')

    [data,~,samplingInterval,chNum] = Nlx_readCSC(fullfile(dataFolder, ['PDes' num2str(i) '.ncs']), computeTS);
    data = data';
    save_aux(i, data, time0, timeend, samplingInterval, trialFolder);
 %   end
end
 
save(fullfile(trialFolder, 'lfpTimeStamps.mat'), 'time0', 'timeend', 'timeStamps', 'samplingInterval'); 

%%

automaticScreeningAnalyze5(trialFolder);

%%
updateChannelMetaData(patient, exp)
[clusterCharacteristics] = calculateClusterCharacteristics(patient, exp, 1, trialFolder);


%%

rasters_by_unit(patient, exp, imageDirectory, 1, 0)
rasters_by_unit(patient, exp, imageDirectory, 0, 0)
rasters_by_image(patient, exp, imageDirectory, 0);

%%
% rasters_by_unit(patient, exp, imageDirectory, 1, 1)
% rasters_by_unit(patient, exp, imageDirectory, 0, 1)


function save_aux(i, data, time0, timeend, samplingInterval, outputDir)
    save(fullfile(outputDir, ['CSC' num2str(i) '.mat']), 'data', 'time0', 'timeend', 'samplingInterval');
end