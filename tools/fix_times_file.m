% fix time units in times_*.mat
% select cluster_class and sortBy and create a new times file.

% In previous versions of wave_clus, timestamps were erroneously multiplied
% by 1000 each time the results were saved, leading to inflated timestamp
% units. This script corrects the timestamps in the times_*.mat files and
% creates corresponding times_manual_*.mat files, containing
% 'cluster_class' and 'sortBy' variables. Future manual curation in
% wave_clus will modify the times_manual files, appending the user's name
% and the date to 'sortBy' to track changes.

clear
searth_path = '/Users/XinNiuAdmin/Downloads/GA4-RAH SERIES';
files = dir(fullfile(searth_path, 'times_G*.mat'));

% set the approximate duration of experiment (in seconds):
ExpDurationSeconds = 2e+04;

skipExists = false;

for i = 1:length(files)
    path = files(i).folder;
    fname = strrep(files(i).name, 'times_', 'times_manual_');
    outFile = fullfile(path, fname);

    if exist(outFile, "file") && skipExists
        fprintf("file exist: %s\n", outFile);
        continue
    end

    load(fullfile(path, files(i).name), 'cluster_class', 'sortedBy');

    min_spike_time = min(cluster_class(:, 2));
    max_spike_time = max(cluster_class(:, 2));
    exp_duration = get_experiment_duration(cluster_class);

    factor = 1;

    while 1
        if exp_duration / factor > ExpDurationSeconds * 100
            factor = factor * 1000;
            fprintf('scale time stamps with factor: %d\n', factor)
        elseif exp_duration / factor < ExpDurationSeconds/100
            factor = factor / 1000;
            fprintf('scale time stamps with factor: %d\n', factor)
        else
            break
        end
    end

    cluster_class(:, 2) = cluster_class(:, 2) / factor;
    exp_duration = get_experiment_duration(cluster_class);

    fprintf("file: %s\n", outFile);
    fprintf("timestamps factor: %d\n", factor);
    fprintf("mean diff on timestamps: %f\n", mean(diff(cluster_class(:, 2))));
    fprintf("duration of experiment (sec): %f\n", exp_duration);

    if factor ~= 1
        save(fullfile(path, files(i).name), 'cluster_class', '-append');
    end

    sortBy = {sortedBy, char(datetime("now"))};
    save(outFile, 'cluster_class', 'sortBy');
end

function exp_duration = get_experiment_duration(cluster_class)
    min_spike_time = min(cluster_class(:, 2));
    max_spike_time = max(cluster_class(:, 2));
    exp_duration = max_spike_time - min_spike_time;
end
