function plot_spike_histogram(spike_times, bin_size, label)
    % plot_spike_histogram Plots the histogram of spike times with sparse x-tick labels
    % spike_times: A vector of spike times (in seconds)
    % bin_size: The size of each time bin (in seconds)
    % label: Title label for the plot

    % Create bin edges
    max_time = ceil(max(spike_times)); % Get the maximum time, rounded up
    bin_edges = 0:bin_size:max_time;   % Define the bin edges

    % Calculate the histogram
    spike_counts = histcounts(spike_times, bin_edges);

    % Find regions with spike_counts = 0 for more than 10 bins
    zero_blocks = find_zero_blocks(spike_counts, 10); % Find zero regions longer than 10 bins

    % Plot the histogram
    figure('Position', [100, 100, 1200, 400]); % Set figure size

    % Add shaded regions for zero blocks
    hold on;
    for i = 1:size(zero_blocks, 1)
        start_time = bin_edges(zero_blocks(i, 1));
        end_time = bin_edges(zero_blocks(i, 2) + 1);
        patch([start_time, end_time, end_time, start_time], ...
              [0, 0, max(spike_counts), max(spike_counts)], ...
              [0.9, 0.9, 0.9], 'EdgeColor', 'none'); % Light gray background
    end

    % Plot the bar histogram
    bar(bin_edges(1:end-1), spike_counts, 'histc', 'FaceColor', [0.2, 0.6, 0.8]);

    % Customize plot appearance
    xlabel('Time (s)', 'FontSize', 12);
    ylabel('Number of Spikes', 'FontSize', 12);
    title(['Spike Count in Each ', num2str(bin_size), '-Second Bin: ', label], 'FontSize', 14);

    % Adjust x-tick labels sparsely
    tick_step = 1000;
    xticks_sparse = 0:tick_step:max_time; % Define sparse x-ticks
    xticks(xticks_sparse);
    xticklabels(arrayfun(@num2str, xticks_sparse, 'UniformOutput', false));
    xtickangle(0); % Rotate x-tick labels for better readability

    hold off;
end

function zero_blocks = find_zero_blocks(spike_counts, min_length)
    % Helper function to find blocks of zeros longer than min_length bins
    % Outputs a Nx2 matrix, where each row is [start_index, end_index] of a zero block
    
    zero_bins = (spike_counts == 0); % Logical array of zero bins
    start_indices = find(diff([0, zero_bins]) == 1); % Start of zero blocks
    end_indices = find(diff([zero_bins, 0]) == -1); % End of zero blocks
    
    % Filter blocks longer than min_length
    block_lengths = end_indices - start_indices + 1;
    valid_blocks = block_lengths > min_length;
    zero_blocks = [start_indices(valid_blocks)', end_indices(valid_blocks)'];
end
