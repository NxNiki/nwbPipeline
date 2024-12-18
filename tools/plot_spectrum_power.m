function plot_spectrum_power(data, timerange, sampling_rate, remove_PLI)
% check spectrum power of raw data with and without removePLI.

if nargin < 3
    sampling_rate = 32000;
end

if nargin < 4
    remove_PLI = false;
end

% Compute start and end sample indices
start_sample = max(1, round(timerange(1) * sampling_rate) + 1);
end_sample = min(length(data), round(timerange(2) * sampling_rate));

% Extract the portion of data within the specified range
data = double(data(start_sample:end_sample));

if remove_PLI
    data = removePLI(data, sampling_rate, numel(60:60:3060), [50 .2 1], [.1 4 1], 2, 60);
end

nfft = 4096*4;
[pxx,fxx] = pwelch(data, hamming(nfft), [], nfft, sampling_rate);

figure;
plot(fxx,10*log10(pxx),'k','LineWidth',1.2)
xlabel('Freq (Hz)')
ylabel('Power (dB/Hz)')
set(gca,'xscale','log')
title(['PSD with nfft=' num2str(nfft)])
set(findall(gcf,'-property','FontSize'),'FontSize',18)