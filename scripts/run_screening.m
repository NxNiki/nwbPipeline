% before run_screening.m, make sure data is unpacked and spike sorted.

clear

patient = 573;
expId = 1;
filePath = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/Screening/573_Screening';


%% parse TTLs:
% this will create TTL.mat and trialStruct.mat
expFilePath = [filePath, '/Experiment', sprintf('%d', expId)];
eventFile = fullfile(expFilePath, 'CSC_events/Events_001.mat');
ttlLogFile = fullfile(expFilePath, "/from laptop/ttlLog573-02-May-2024-14-54-53.mat");

trials = parseTTLs_Screening(eventFile, ttlLogFile);

%% 
imageDirectory = fullfile(expFilePath, '/trial1');
cscFilePath = fullfile(expFilePath, '/CSC_micro');
spikeFilePath = [filePath, '/Experiment', sprintf('-%d', expId), '/CSC_micro_spikes'];

[clusterCharacteristics] = calculateClusterCharacteristics(spikeFilePath, cscFilePath, trials);
% [clusterCharacteristics] = calculateClusterCharacteristics_video(patient, exp, imageDirectory);

save(fullfile(spikeFilePath, 'clusterCharacteristics.mat'), 'clusterCharacteristics');
%%

command = ['chmod -R 775 ', filePath];
system(command)


%%

rasters_by_unit(patient, exp, imageDirectory, 1, 0)
rasters_by_unit(patient, exp, imageDirectory, 0, 0)

rasters_by_image(patient, exp, imageDirectory, 0);

%%

% rasters_by_unit_video(patient, exp, imageDirectory, 1, 0)
rasters_by_unit_video(patient, exp, imageDirectory, 0, 0)
rasters_by_image(patient, exp, imageDirectory, 0);



