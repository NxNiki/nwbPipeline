function plotSignalSpectrum(signal1, signal2, signal3, tsInterval, titleName)

transparency = .5;

% Plot the resampled signals
figure;
signalVal1 = signal1.value(signal1.ts>=tsInterval(1) & signal1.ts<=tsInterval(2));
samplingRate = (length(signal1.ts) - 1) / (signal1.ts(end) - signal1.ts(1));

[pxx, fxx] = spectrumDecomposition(signalVal1, samplingRate);
plot(fxx, pxx, 'LineWidth', 1.5, 'LineStyle', '-', 'Color', [0.1, 0.7, 0.2, .9]);
legendLabels = {signal1.label};

if ~isempty(signal2)
    signalVal2 = signal2.value(signal2.ts>=tsInterval(1) & signal2.ts<=tsInterval(2));
    samplingRate = (length(signal2.ts) - 1) / (signal2.ts(end) - signal2.ts(1));
    [pxx, fxx] = spectrumDecomposition(signalVal2, samplingRate);
    hold on;
    plot(fxx, pxx, 'LineWidth', 1.5, 'LineStyle', '--', 'Color', [0.7, 0.1, 0.2, transparency]);
    legendLabels = [legendLabels, {signal2.label}];
end

if ~isempty(signal3)
    signalVal3 = signal3.value(signal3.ts>=tsInterval(1) & signal3.ts<=tsInterval(2));
    samplingRate = (length(signal3.ts) - 1) / (signal3.ts(end) - signal3.ts(1));
    [pxx, fxx] = spectrumDecomposition(signalVal3, samplingRate);
    hold on;
    plot(fxx, pxx, 'LineWidth', 1.5, 'LineStyle', '--', 'Color', [0.2, 0.1, 0.7, transparency]);
    legendLabels = [legendLabels, {signal3.label}];
end

xlabel('Frequency');
ylabel('Spectrum Power');

legend(legendLabels);
title(strrep(titleName, '_', ' '), 'FontSize', 16);

end

function [pxx, fxx] = spectrumDecomposition(signal, samplingRate)

windowLengthSeconds = .1;
nfft = 2^(nextpow2(samplingRate * windowLengthSeconds)); % for a roughly 1 second window
win  = hanning(nfft);
noverlap = [];          % amount of overlap of sections for psd ([] = default = 50% overlap)
[pxx,fxx] = pwelch(signal(:)', win, noverlap, nfft, samplingRate);
pxx = 10*log10(pxx);

pxx = pxx(6:floor(length(pxx)/16));
fxx = fxx(6:floor(length(fxx)/16)); % up to 1000 Hz.

end

