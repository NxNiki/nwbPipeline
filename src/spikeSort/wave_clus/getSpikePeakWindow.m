function peakWindow = getSpikePeakWindow(spikes)

    [~, spikePeakIdx] = max(abs(mean(spikes, 1)));
    peakWindow = spikePeakIdx - 5: spikePeakIdx + 5;

end