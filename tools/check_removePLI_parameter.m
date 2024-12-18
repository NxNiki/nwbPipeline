% plot SPD to verify removePLI parameters.

% cscFile = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/Screening/578_Screening/Experiment-1/CSC_micro/GB2-LOF3.mat';
cscFile = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/Screening/578_Screening/Experiment-1/CSC_micro/GA1-LEC1.mat';

removePliParam.M = 50;
removePliParam.B = [50 .2 1];
removePliParam.P = [.1 4 1];
removePliParam.W = 2;
removePliParam.f_ax = 60;
flimits = [0, 100];

[data, samplingInterval] = readCSC(cscFile);
% data = data(1:min(length(data), 1e7));

figure('Position', [1, 1, 1400, 900]);
titleLabel = strrep(extractAfter(cscFile, 'ANALYSIS'), '_', '\_');

[T, F, P] = get_psd(data, samplingInterval, flimits);
ax = axes('position', [0.1,0.51,0.8,0.39]);
plot_psd(T, F, P, ax, strrep(titleLabel, '.mat', ''));

data = removePLI(data, 1/samplingInterval, removePliParam.M, removePliParam.B, removePliParam.P, removePliParam.W, removePliParam.f_ax);
[T, F, P] = get_psd(data, samplingInterval, flimits);

ax = axes('position', [0.1,0.1,0.8,0.39]);
plot_psd(T, F, P, ax, strrep(titleLabel, '.mat', '\_removePLI'));


function [T, F, P] = get_psd(data, samplingInterval, flimits)

window = 30*(1/samplingInterval);
[~,F,T,P]  = spectrogram(double(data), window, 0.8*window, (0.5:.2:flimits(2)), 1/samplingInterval, 'yaxis');
P = P/max(max(P));
P = (10*log10(abs(P+2e-4)))';
P = [P(:,1) P P(:,end)];
T = [0 T T(end)+1];
P = imgaussfilt(P',3);

end

function plot_psd(T, F, P, ax, titleLabel)
imagesc(T,F,P, [-40, -15]);axis xy;
xlimits = [0 T(end)];
xticks = 1:(60*60):T(end);
for i = 1:length(xticks)
    xlabel_str{i} = num2str(floor((xticks(i)/(60*60))));
end

yticks = 0:5:F(end);
axis([xlimits [0, F(end)]])
set(ax,'xtick',xticks,'XTickLabel', xlabel_str)
colorbar
axis([get(ax,'xlim'), [0.5, F(end)]])
set(ax,'ytick', yticks)

xlabel('t (hr)')
ylabel('f (Hz)')
title(titleLabel);
end