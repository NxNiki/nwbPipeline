
filePath = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/570_MovieParadigm/';
expIds = 4:7;
lfpFs = 2000;
expFilePath = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/570_MovieParadigm/Experiment-4-5-6-7_debug';

microFiles = {
    '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/570_MovieParadigm/Experiment-4/CSC_micro/GA4-RPHG6_001.mat';
    '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/570_MovieParadigm/Experiment-4/CSC_micro/GA4-RPHG6_002.mat';
    '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/570_MovieParadigm/Experiment-5/CSC_micro/GA4-RPHG6_001.mat';
    '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/570_MovieParadigm/Experiment-5/CSC_micro/GA4-RPHG6_002.mat';
    '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/570_MovieParadigm/Experiment-5/CSC_micro/GA4-RPHG6_003.mat'; 
    '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/570_MovieParadigm/Experiment-5/CSC_micro/GA4-RPHG6_004.mat'; 
    '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/570_MovieParadigm/Experiment-5/CSC_micro/GA4-RPHG6_005.mat'; 
    '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/570_MovieParadigm/Experiment-6/CSC_micro/GA4-RPHG6_001.mat'; 
    '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/570_MovieParadigm/Experiment-7/CSC_micro/GA4-RPHG6_001.mat'
    }';

spikeDetectFiles = {'/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/570_MovieParadigm/Experiment-4-5-6-7/CSC_micro_spikes/GA4-RPHG4_spikes.mat'};
spikeClusterFiles = {'/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/570_MovieParadigm/Experiment-4-5-6-7/CSC_micro_spikes/times_GA4-RPHG4.mat'};
skipExist =  0;


[~, microTimestampFiles] = readFilePath(expIds, filePath, 'micro');

lfpTimestamps = downsampleTimestamps(microTimestampFiles, microTimestampFiles, lfpFs, expFilePath);

lfpFiles = extractLFP(microFiles, microTimestampFiles, lfpTimestamps, spikeDetectFiles, spikeClusterFiles, microLFPPath, skipExist);