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
channelName = extractChannelName(fname);
fname1 = [channelName, '_spikes.mat'];

end

function fname1 = makeSpikeClusteringFileName(fname)

[~, fname] = fileparts(fname);
channelName = extractChannelName(fname);
fname1 = ['times_', channelName, '.mat'];

end

function channelName = extractChannelName(fname)

% remove digit suffix in file name:
channelName = regexp(fname, '.*(?=_\d+)', 'match', 'once');
if isempty(channelName)
    channelName = fname;
end
end

