function timesFile = spikeFile2TimesFile(spikesFile)

if isempty(spikesFile)
    timesFile = '';
    return;
end

[filePath, spikesFile, ext] = fileparts(spikesFile);

channel = strrep(spikesFile, '_spikes', '');
timesFile = fullfile(filePath, ['times_', channel, ext]);

end