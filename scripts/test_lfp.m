

% cscfile = {'/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/Screening/566_Screening/Experiment2/CSC_data/CSC17.mat'};
% spikefile = {'/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/Screening/566_Screening/Experiment2/CSC_data/times_CSC17.mat'};
% timestampfile = {'/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/Screening/566_Screening/Experiment2/CSC_data/lfpTimeStamps.mat'};


% 569 screening 1 (Exp 2) CSC35 Unit 2 RA (1/1)
% !!! patient 569 has mis match in signal and spike time stamps...
cscfile = {'/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/Screening/569_Screening/Experiment2/CSC_data/CSC35.mat'};
spikefile = {'/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/Screening/569_Screening/Experiment2/CSC_data/times_CSC35.mat'};
timestampfile = {'/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/Screening/569_Screening/Experiment2/CSC_data/lfpTimeStamps.mat'};


% timestamps in this file is 0 based which is different from new data with
% nwbpipeline.
microLFPPath = '/Users/XinNiuAdmin/Documents/NWBTest/output/Screening/569_Screening/lfp_test';


skipExist = 0; 
saveRawSignal = true;

lfpFiles = extractLFP(cscfile, timestampfile, spikefile, microLFPPath, '', skipExist, saveRawSignal);
