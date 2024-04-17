

cscfile = {'/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/Screening/566_Screening/Experiment2/CSC_data/CSC17.mat'};
spikefile = {'/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/Screening/566_Screening/Experiment2/CSC_data/times_CSC17.mat'};
timestampfile = {'/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/Screening/566_Screening/Experiment2/CSC_data/lfpTimeStamps.mat'};
% timestamps in this file is 0 based which is different from new data with
% nwbpipeline.
microLFPPath = '/Users/XinNiuAdmin/Documents/NWBTest/output/Screening/566_Screening/lfp_test';


skipExist = 0; 
saveRawSignal = true;

lfpFiles = extractLFP(cscfile, timestampfile, spikefile, microLFPPath, '', skipExist, saveRawSignal);
