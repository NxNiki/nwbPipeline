function isInverted = checkSpikeDirection(signal, spikeWaveForm)
% check if the waveform of spikes and the raw signals is inverted or not.
% unfinished and may not be necessary if the spike detection is correct.

signal = signal - median(signal);
[~, peakIndex] = max(spikeWaveForm);
spikeSignalCorr = corr(signal, spikeWaveForm);
isInverted = ((spikeSignalCorr < 0) - .5) * 2; % if correlation < 0 isInverted is 1 else -1.
isInverted = isInverted * (abs(spikeSignalCorr) > spikeSignalCorrThresh);
end
