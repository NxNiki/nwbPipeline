% fix time units in times_*.mat

clear
path = '/Users/XinNiuAdmin/Library/CloudStorage/Box-Box/cnl_meetings/spike_sorting/561 Experiment-3-4-5/CSC_micro_spikes';
files = dir(fullfile(path, 'times_*.mat'));
ExpDurationSeconds = 4.1315e+04;

for i = 1:length(files)
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
end
