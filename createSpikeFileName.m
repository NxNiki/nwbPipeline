function [spikeDetectionFileName, spikeClusteringFileName ] = createSpikeFileName(cscFileName)
% create output filenames for spike detection and clustering. 
% For now, the downstream analysis requires them with pattern:
% *_spikes.mat and times_*.mat respectively.
% the cscFileName has pattern: '*_001.mat'. We will remove the suffix in
% the outputs.


if iscell(cscFileName)
    spikeDetectionFileName = cellfun(@spikeDetection, cscFileName, UniformOutput=false);
    spikeClusteringFileName = cellfun(@spikeClustering, cscFileName, UniformOutput=false);
else
    spikeDetectionFileName = spikeDetection(cscFileName);
    spikeClusteringFileName = spikeClustering(cscFileName);
end
end

function fname1 = spikeDetection(fname)

[~, fname] = fileparts(fname);
fname1 = [regexp(fname, '.*(?=_\d+)', 'match', 'once'), '_spikes.mat'];
end

function fname1 = spikeClustering(fname)

[~, fname] = fileparts(fname);
fname1 = ['times_', regexp(fname, '.*(?=_\d+)', 'match', 'once'), '.mat'];

end

