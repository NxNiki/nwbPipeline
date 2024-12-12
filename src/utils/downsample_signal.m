function downsampled_signal = downsample_signal(signal, original_rate, target_rate)
    % DOWNSAMPLE_SIGNAL Downsample a signal from original_rate to target_rate.
    %
    % Parameters:
    %   signal (vector): The input signal to be downsampled.
    %   original_rate (scalar): The original sampling rate of the signal (default: 2000 Hz).
    %   target_rate (scalar): The target sampling rate (default: 200 Hz).
    %
    % Returns:
    %   downsampled_signal (vector): The downsampled signal.
    
    % Set default values if not provided
    if nargin < 2
        original_rate = 2000;
    end
    if nargin < 3
        target_rate = 200;
    end
    
    % Compute the downsampling factor
    downsample_factor = original_rate / target_rate;
    
    if mod(downsample_factor, 1) ~= 0
        error('Downsampling factor must be an integer. Please adjust the rates.');
    end
    
    % Apply a low-pass anti-aliasing filter
    signal_filtered = lowpass(signal, target_rate / 2, original_rate);

    % Downsample the signal
    downsampled_signal = signal_filtered(1:downsample_factor:end);
end
