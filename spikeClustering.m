function clusterSpikes(subject,exp,sr,overwriteOrListOfFiles)

% If you are using this in conjunction with the database, the standard
% input is patientNumber followed by experiment number. 
% Otherwise, the first argument can be the path to the folder where the
% CSC_spikes files are located and the second argument can be left empty.
% The next argument, sr, is sampling rate (in Hz). If not passed in, it
% will be determined from a csc_file.
% Final (optional) argument is a single logical indicating whether to
% overwrite previous clustering results (default no) OR a list of files to
% cluster. If not passed in or empty, it will cluster all files. If list is
% passed in, it will assume overwrite.

originalDir = pwd;

if ischar(subject)
    trialFolder = subject;
else
info = getExperimentInfo(subject,exp);
if isfield(info,'linkToConvertedData')
    trialFolder = info.linkToConvertedData;
else
    trialFolder = info.rawUnpacked;
end
end

if ~exist('sr','var') || isempty(sr)
csc_files = dir(fullfile(trialFolder, 'CSC*.mat'));

si = load(fullfile(trialFolder,csc_files(1).name),'samplingInterval');
sr = 1000/si.samplingInterval;
end

if ~exist('overwriteOrListOfFiles','var') || isempty(overwriteOrListOfFiles)
    overwriteOrListOfFiles = 0;
    spike_files = dir(fullfile(trialFolder, 'CSC*_spikes.mat'));
    spike_files = {spike_files.name};
else
    spike_files = overwriteOrListOfFiles;
    if isnumeric(spike_files)
        spike_files = arrayfun(@(x)sprintf('CSC%d_spikes.mat',x), spike_files, 'uniformoutput', 0);
    end
    overwriteOrListOfFiles = 1;
end

min_spikes4SPC = 16;
% Create par object to pass to wave_clus functions
    par = set_parameters();
    par.ref = floor(1.5 *sr/1000);
    par.sr = sr;
    
    
cd(trialFolder);

for fnum = 1:length(spike_files)
    filename = fullfile(trialFolder, spike_files{fnum});
    outfile = sprintf('times_%s',strrep(spike_files{fnum},'_spikes',''));
    if overwriteOrListOfFiles || ~exist(fullfile(trialFolder,outfile),'file')
        do_clustering_single_AS(filename,min_spikes4SPC, par, par, fnum);
    end
end

%Do_clustering(clusteringFileName);
cd(originalDir);