function spikeClustering(spikeFiles, spikeCodeFiles, outputPath, skipExist)

% spikeFiles: cell(n, 1). the fullpath of spike files.
% outputPath: str. 
% skipExist: bool.


makeOutputPath(spikeFiles, outputPath, skipExist)

min_spikes4SPC = 16;

for fnum = 1:length(spikeFiles)

    filePath = spikeFiles{fnum};
    [~, filename, ext] = fileparts(filePath);
    outfile = sprintf('times_%s%s', strrep(filename, '_spikes', ''), ext);
    if skipExist && exist(fullfile(outputPath, outfile), 'file')
        continue
    end
    fprintf('clustering spikes:\n %s\n', filePath);
    
    % run spike clustering
    do_clustering_single_AS(filePath, spikeCodeFiles{fnum}, outputPath, min_spikes4SPC);

end
