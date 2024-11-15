% wave_clus will not create times_manual file if no manual curation is
% applied (only when go to next file wtihout saving). This script create
% times_manual file by copy cluster_class in the times file.

clear
search_path = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/570_MovieParadigm/Experiment-4-5-6-7/CSC_micro_spikes/';
files = dir(fullfile(search_path, '/times_G*.mat'));

for i = 1:length(files)
    path = files(i).folder;
    fname = strrep(files(i).name, 'times_', 'times_manual_');
    timesFile = fullfile(path, files(i).name);
    timesManualFile = fullfile(path, fname);

    if exist(timesManualFile, "file")
        continue
    end

    load(timesFile, 'cluster_class', 'timestampsStart');

    fprintf("times file: %s\n", timesManualFile);
    fprintf("times manual file: %s\n", fullfile(path, files(i).name));

    save(timesManualFile, 'cluster_class', 'timestampsStart');
end
