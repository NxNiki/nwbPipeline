function spikeAmplitude = getSpikeAmplitude(spikes, peakWindow)

spikeAmplitude = max(abs(spikes(:, peakWindow)), [], 2);

end