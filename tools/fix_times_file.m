% fix time units in times_*.mat
% select cluster_class and sortBy and create a new times file.

clear
searth_path = '/Users/XinNiuAdmin/HoffmanMount/bfalken/MICROS';
files = dir(fullfile(searth_path, '**/times_*.mat'));
ExpDurationSeconds = 5.1315e+04;

for i = 1:length(files)
    path = files(i).folder;
    load(fullfile(path, files(i).name), 'cluster_class');

    min_spike_time = min(cluster_class(:, 2));
    max_spike_time = max(cluster_class(:, 2));

    factor = 1;

    while 1
        if min_spike_time / factor < .1
            break
        end

        if (max_spike_time - min_spike_time) / factor > ExpDurationSeconds
            factor = factor * 1000;
            disp('scale time stamps')
        else
            break
        end
    end

    files(i).name
    factor
    cluster_class(:, 2) = cluster_class(:, 2) / factor;
    mean(diff(cluster_class(:, 2)))
    max(cluster_class(:, 2)) - min(cluster_class(:, 2))

    save(fullfile(path, files(i).name), 'cluster_class', '-append');

    fname = strrep(files(i).name, 'times_', 'times_manual_');
    sortBy = {'Ben', char(datetime("now"))};
    save(fullfile(path, fname), 'cluster_class', 'sortBy');
end
