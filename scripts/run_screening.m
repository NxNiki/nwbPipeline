
patient = 569;
exp = 2;

trialFolder = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/Screening/569_Screening/Experiment2/CSC_data';
imageDirectory = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/Screening/569_Screening/Experiment2/Screening_1/trial1';

addpath(genpath('/Users/XinNiuAdmin/Documents/MATLAB/DataPipeline_Screening'));
rmpath(genpath('/Users/XinNiuAdmin/Documents/MATLAB/DataPipeline_Screening/Utilities/chronux'));



%%
automaticScreeningAnalyze5(trialFolder);
updateChannelMetaData(patient, exp)
[clusterCharacteristics] = calculateClusterCharacteristics(patient, exp, 1);

rasters_by_unit(patient, exp, imageDirectory, 1, 0)
rasters_by_unit(patient, exp, imageDirectory, 0, 0)
rasters_by_image(patient, exp, imageDirectory, 0);

