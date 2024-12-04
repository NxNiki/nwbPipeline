function plot_raw_signal(data, timerange, sampling_rate, label)
    % Function to plot raw CSC signal with time as x-axis in seconds
    %
    % Inputs:
    %   - data: Array of raw CSC signal values
    %   - timerange: Vector [start, end] indicating the time range (in seconds)
    %   - sampling_rate: Sampling rate of the signal (in Hz)
    %   - label: Cell array of strings for legend labels
    %
    % Example:
    %   plot_raw_signal(signal, [10, 20], 1000, {'Channel 1', 'Channel 2'});

    % Default sampling rate if not provided
    if nargin < 3
        sampling_rate = 32000;
    end

    % Validate timerange
    if length(timerange) ~= 2 || timerange(1) >= timerange(2)
        error('timerange must be a 2-element vector [start, end] with start < end.');
    end

    % Validate label
    if nargin < 4 || isempty(label)
        label = arrayfun(@(x) sprintf('Channel %d', x), 1:size(data, 1), 'UniformOutput', false);
    elseif length(label) ~= size(data, 1)
        error('The length of label must match the number of channels in data.');
    end

    % Compute start and end sample indices
    start_sample = max(1, round(timerange(1) * sampling_rate) + 1);
    end_sample = min(length(data), round(timerange(2) * sampling_rate));

    % Extract the portion of data within the specified range
    selected_data = data(:, start_sample:end_sample);

    % Generate corresponding time vector in seconds
    time_vector = (start_sample:end_sample) / sampling_rate;

    % Compute correlation if multiple channels
    if size(selected_data, 1) > 1
        r = corr(single(selected_data)');
        fprintf('Correlation Matrix:\n');
        disp(r);
    else
        r = []; % No correlation for single channel
    end

    % Create figure with adjusted size
    figure('Position', [100, 100, 1500, 600]); % Adjust figure size

    % Plot the signal
    hold on;
    for i = 1:size(selected_data, 1)
        plot(time_vector, selected_data(i, :), 'DisplayName', label{i}, 'LineStyle', '--');
    end
    hold off;

    % Add labels, legend, and title
    xlabel('Time (s)');
    ylabel('Signal Amplitude');
    title('Raw CSC Signal');
    legend('show', 'Location', 'best');
    
    % Adjust x-ticks to be in seconds
    xticks(linspace(timerange(1), timerange(2), 10)); % 10 evenly spaced ticks
    grid on;

    % Display correlation matrix as a text annotation if available
    if ~isempty(r)
        annotation('textbox', [0.15, 0.75, 0.1, 0.1], 'String', sprintf('Corr: %.3f', r(2,1)), ...
            'FitBoxToText', 'on', 'BackgroundColor', 'white');
    end
end
