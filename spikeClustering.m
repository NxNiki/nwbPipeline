function spikeClustering(spikeFiles, outputPath, skipExist)

% spikeFiles: cell(n, 1). the fullpath of spike files.
% outputPath: str. 
% skipExist: bool.


makeOutputPath(spikeFiles, outputPath, skipExist)

min_spikes4SPC = 16;

parfor fnum = 1:length(spikeFiles)

    filename = spikeFiles{fnum};
    fprintf('clustering spikes:\n %s\n', filename);

    spikeFileObj = matfile(filename, 'Writable', false);
    par = spikeFileObj.param;
    
    outfile = sprintf('times_%s',strrep(filename,'_spikes',''));
    if skipExist && exist(fullfile(outputPath, outfile), 'file')
        continue
    end
    do_clustering_single_AS(filename, outputPath, min_spikes4SPC, par);

end
