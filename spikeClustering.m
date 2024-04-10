function spikeClustering(spikeFiles, exp, sr, overwriteOrListOfFiles)

% Otherwise, the first argument can be the path to the folder where the
% CSC_spikes files are located and the second argument can be left empty.
% The next argument, sr, is sampling rate (in Hz). If not passed in, it
% will be determined from a csc_file.
% Final (optional) argument is a single logical indicating whether to
% overwrite previous clustering results (default no) OR a list of files to
% cluster. If not passed in or empty, it will cluster all files. If list is
% passed in, it will assume overwrite.



if ~exist('sr','var') || isempty(sr)
csc_files = dir(fullfile(trialFolder, 'CSC*.mat'));

si = load(fullfile(trialFolder,csc_files(1).name),'samplingInterval');
sr = 1000/si.samplingInterval;
end

if ~exist('overwriteOrListOfFiles','var') || isempty(overwriteOrListOfFiles)
    overwriteOrListOfFiles = 0;
    spikeFiles = dir(fullfile(trialFolder, 'CSC*_spikes.mat'));
    spikeFiles = {spikeFiles.name};
else
    spikeFiles = overwriteOrListOfFiles;
    if isnumeric(spikeFiles)
        spikeFiles = arrayfun(@(x)sprintf('CSC%d_spikes.mat',x), spikeFiles, 'uniformoutput', 0);
    end
    overwriteOrListOfFiles = 1;
end

min_spikes4SPC = 16;
% Create par object to pass to wave_clus functions
par = set_parameters();
par.ref = floor(1.5 *sr/1000);
par.sr = sr;

for fnum = 1:length(spikeFiles)
    filename = fullfile(trialFolder, spikeFiles{fnum});
    outfile = sprintf('times_%s',strrep(spikeFiles{fnum},'_spikes',''));
    if overwriteOrListOfFiles || ~exist(fullfile(trialFolder,outfile),'file')
        do_clustering_single_AS(filename,min_spikes4SPC, par, par, fnum);
    end
end
