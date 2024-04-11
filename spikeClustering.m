function spikeClustering(spikeFiles, outputPath, skipExist)

% spikeFiles: cell(n, 1). the fullpath of spike files.
% outputPath: str. 
% skipExist: bool.


inputPath = fileparts(spikeFiles{1});
if ~exist(outputPath, "dir")
    mkdir(outputPath);
elseif ~skipExist  && ~strcmp(inputPath, outputPath)
    % create an empty dir to avoid not able to resume with unprocessed
    % files in the future if this job fails. e.g. if we have 10 files
    % processed at time1, at time2 it stops with 5 files processed, we
    % cannot start with the 6th file at time3 as we have 10 files saved.

    % ideally we should set a different outputPath to make skipExist works
    % but the clustering functions may assume them in the same directory
    % (or not?) and name with specific patterns (times_*.mat and
    % *_spikes.mat)
    rmdir(outputPath, 's');
    mkdir(outputPath);
end

min_spikes4SPC = 16;

for fnum = 1:length(spikeFiles)

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
