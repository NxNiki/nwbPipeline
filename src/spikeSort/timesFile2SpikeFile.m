function spikesFile = timesFile2SpikeFile(timesFile)

if isempty(timesFile)
    spikesFile = '';
    return;
end

[filePath, timesFile, ext] = fileparts(timesFile);

channel = strrep(timesFile, 'times_', '');
spikesFile = fullfile(filePath, [channel, '_spikes', ext]);

end