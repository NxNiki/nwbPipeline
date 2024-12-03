function plot_raw_signal(data, timerange, sampling_rate)
    % Function to plot raw CSC signal with time as x-axis in seconds
    %
    % Inputs:
    %   - data: Array of raw CSC signal values
    %   - timerange: Vector [start, end] indicating the time range (in seconds)
    %   - sampling_rate: Sampling rate of the signal (in Hz)
    %
    % Example:
    %   plot_raw_signal(signal, [10, 20], 1000)

    % Check inputs
    if nargin < 3
        sampling_rate = 32000;
    end
    
    if length(timerange) ~= 2 || timerange(1) >= timerange(2)
        error('timerange must be a 2-element vector [start, end] with start < end.');
    end

    % Compute start and end sample indices
    start_sample = max(1, round(timerange(1) * sampling_rate) + 1);
    end_sample = min(length(data), round(timerange(2) * sampling_rate));

    % Extract the portion of data within the specified range
    selected_data = data(:, start_sample:end_sample);

    corr(single(selected_data)')

    % Generate corresponding time vector in seconds
    time_vector = (start_sample:end_sample) / sampling_rate;

    % Plot the signal
    figure;
    plot(time_vector, selected_data);
    xlabel('Time (s)');
    ylabel('Signal Amplitude');
    title('Raw CSC Signal');
    
    % Adjust x-ticks to be in seconds
    xticks(linspace(timerange(1), timerange(2), 10)); % 10 evenly spaced ticks
    grid on;
end
