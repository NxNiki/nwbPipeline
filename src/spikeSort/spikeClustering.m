function spikeClustering(spikeFiles, spikeCodeFiles, outputPath, skipExist)

% spikeFiles: cell(n, 1). the fullpath of spike files.
% outputPath: str.
% skipExist: bool.


makeOutputPath(spikeFiles, outputPath, skipExist)

min_spikes4SPC = 16;

parfor fnum = 1:length(spikeFiles)

    spikeFile = spikeFiles{fnum};
    [~, filename, ext] = fileparts(spikeFile);
    outfile = sprintf('times_%s%s', strrep(filename, '_spikes', ''), ext);
    if skipExist && exist(fullfile(outputPath, outfile), 'file')
        continue
    end

    if isempty(spikeCodeFiles)
        spikeCodeFile = '';
    else
        spikeCodeFile = spikeCodeFiles{fnum};
    end

    fprintf('run cluster analysis on spikes:\n spike file: %s\n spikeCode file: %s\n', spikeFile, spikeCodeFile);

    % run spike clustering
    do_clustering_single_AS(spikeFile, spikeCodeFile, outputPath, min_spikes4SPC);

end
