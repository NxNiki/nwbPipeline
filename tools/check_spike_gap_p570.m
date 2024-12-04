close;
sampling_rate = 32000;
remove_pli = false;
filter = true;
bin_size = 10; % seconds.


%% plot raw signal:

file_path = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/570_MovieParadigm/Experiment-4/CSC_micro/';
% csc_file1 = 'GA1-REC1_001.mat';
% csc_file2 = 'GA1-REC2_001.mat';
csc_file1 = 'GA3-RMH1_001.mat';
csc_file2 = 'GA3-RMH2_001.mat';

data = read_csc_data(file_path, csc_file1, csc_file2, filter);
% plot_raw_signal(data, [300, 800], sampling_rate, {csc_file1, csc_file2});

%% plot PSD:
% plot_spectrum_power(data(1, :), [300, 800], sampling_rate, true);
plot_spectrum_power(data(1, :), [300, 800], sampling_rate, false);

%% plot spike histgram:

file_path = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/570_MovieParadigm/Experiment-4/CSC_micro_spikes_removePLI';
% file_path = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/570_MovieParadigm/Experiment-4/CSC_micro_spikes';

% spike_file1 = 'times_GA3-RMH1.mat';
% spike_file1 = 'GA1-REC1_spikes.mat';
spike_file1 = 'times_GB1-LA4.mat';
% spike_file1 = 'GB1-LA4_spikes.mat';

spike_times = read_spike_data(file_path, spike_file1);
% plot_spike_histogram(spike_times, bin_size, spike_file1);

plot_spike_histogram(spike_times, bin_size, spike_file1);

%%

function data = read_csc_data(file_path, file1, file2, remove_pli, filter)
 
    f1 = matfile(fullfile(file_path, file1));
    f2 = matfile(fullfile(file_path, file2));

    data = [f1.data, f2.data]';

    % if remove_pli
    %     data(1,:) = removePLI(data(1,:), sampling_rate, numel(60:60:3060), [50 .2 1], [.1 4 1], 2, 60);
    %     data(2,:) = removePLI(data(2,:), sampling_rate, numel(60:60:3060), [50 .2 1], [.1 4 1], 2, 60);
    % end

end

function spike_times = read_spike_data(file_path, file)

    f = matfile(fullfile(file_path, file));
    if any(strcmp(who(f), 'cluster_class'))
        cluster_class = f.cluster_class;
        spike_times = cluster_class(:, 2);
    else
        spike_times = f.spikeTimestamps;
    end

end