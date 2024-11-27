function plot_spike_histogram(spike_times, bin_size)
    % plot_spike_histogram Plots the histogram of spike times with sparse x-tick labels
    % spike_times: A vector of spike times (in seconds)
    % bin_size: The size of each time bin (in seconds)
    % tick_step: Step size for x-tick labels (in seconds)

    % Create bin edges
    max_time = ceil(max(spike_times)); % Get the maximum time, rounded up
    bin_edges = 0:bin_size:max_time;   % Define the bin edges

    % Calculate the histogram
    spike_counts = histcounts(spike_times, bin_edges);

    % Plot the histogram
    figure('Position', [100, 100, 1200, 400]); % Set figure size
    bar(bin_edges(1:end-1), spike_counts, 'histc', 'FaceColor', [0.2, 0.6, 0.8]);
    xlabel('Time (s)', 'FontSize', 12);
    ylabel('Number of Spikes', 'FontSize', 12);
    title(['Spike Count in Each ', num2str(bin_size), '-Second Bin'], 'FontSize', 14);

    % Adjust x-tick labels sparsely
    tick_step = 1000;
    xticks_sparse = 0:tick_step:max_time; % Define sparse x-ticks
    xticks(xticks_sparse);
    xticklabels(arrayfun(@num2str, xticks_sparse, 'UniformOutput', false));
    xtickangle(0); % Rotate x-tick labels for better readability
    % 
    % % Add grid
    % grid on;
end

