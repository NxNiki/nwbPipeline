function [spikeDetectionFileName, spikeClusteringFileName ] = createSpikeFileName(cscFileName)
% create output filenames for spike detection and clustering.
% For now, the downstream analysis requires them with pattern:
% *_spikes.mat and times_*.mat respectively.
% the cscFileName has pattern: '*_001.mat'. We will remove the suffix in
% the outputs.


if iscell(cscFileName)
    spikeDetectionFileName = cellfun(@makeSpikeDetectionFileName, cscFileName, UniformOutput=false);
    spikeClusteringFileName = cellfun(@makeSpikeClusteringFileName, cscFileName, UniformOutput=false);
else
    spikeDetectionFileName = makeSpikeDetectionFileName(cscFileName);
    spikeClusteringFileName = makeSpikeClusteringFileName(cscFileName);
end
end

function fname1 = makeSpikeDetectionFileName(fname)

[~, fname] = fileparts(fname);
channelName = extractChannelName(fname, '.*(?=_\d+)');
fname1 = [channelName, '_spikes.mat'];

end

function fname1 = makeSpikeClusteringFileName(fname)

[~, fname] = fileparts(fname);
channelName = extractChannelName(fname, '.*(?=_\d+)');
fname1 = ['times_', channelName, '.mat'];

end
