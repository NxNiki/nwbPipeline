% Define parameters
samplingRate = 1000; % Sampling rate (Hz)
windowLengthSeconds = .1; % Window length in seconds
overlap = 0.5; % Overlap between windows (50% overlap)
signal = sin(1:1000) + 2*sin(1:1000); % 1000 samples, 5 channels
signal2 = 3*sin(1:1000) + 4*sin(1:1000);

signal = [signal, signal2];
nfft = 2^(nextpow2(samplingRate * windowLengthSeconds)); % FFT length for each window

% Calculate spectrogram
figure;
spectrogram(signal, hamming(nfft), round(overlap*nfft), nfft, samplingRate, 'yaxis');
title('Spectrogram');
xlabel('Time (s)');
ylabel('Frequency (Hz)');
colorbar; % Add a colorbar to indicate power

