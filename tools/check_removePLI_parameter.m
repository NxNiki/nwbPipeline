% plot SPD to verify removePLI parameters.

% cscFile = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/Screening/578_Screening/Experiment-1/CSC_micro/GB2-LOF3.mat';
% cscFile = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/Screening/578_Screening/Experiment-1/CSC_micro/GA1-LEC1.mat';
% cscFile = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/Screening/578_Screening/Experiment-1/CSC_micro/GA4-LFSG1.mat';
cscFile = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/Screening/579_Screening/Experiment-2/CSC_micro/GA4-RFSG6_001.mat';

removePliParam.M = 50; % number of harmonics to remove
removePliParam.B = [50 .2 1];
removePliParam.P = [.1 4 1];
removePliParam.W = 2; % recommend value: .5 - 5.
removePliParam.f_ax = 60;
flimits = [0, 65];

[data, samplingInterval] = readCSC(cscFile);
% data = data(1:min(length(data), 5e7));

figure('Position', [100, 100, 1400, 900]);
titleLabel = strrep(extractAfter(cscFile, 'ANALYSIS'), '_', '\_');

margin = .05;
rightWidth = .55;
leftWidth = 1 - margin * 3 - rightWidth;
height = (1 - margin * 4)/3;

[T, F, P] = get_psd(data, samplingInterval, flimits);
ax = axes('position', [margin, 3*margin+2*height, rightWidth, height]);
plot_spectrogram(T, F, P, ax, strrep(titleLabel, '.mat', ''));

nfft = 4096*4;
[p, f] = pwelch(data, hamming(nfft), [], nfft, 1/samplingInterval);
ax = axes('position', [margin*2+rightWidth, 3*margin+2*height, leftWidth, height]);
p = 10*log10(p+2e-4);
plot_psd(f, p, ax, nfft)

fprintf('run removePLI...\n')
tic
data = removePLI(data, 1/samplingInterval, removePliParam.M, removePliParam.B, removePliParam.P, removePliParam.W, removePliParam.f_ax);
toc
[T, F, P2] = get_psd(data, samplingInterval, flimits);

ax = axes('position', [margin, 2*margin+height, rightWidth, height]);
plot_spectrogram(T, F, P2, ax, strrep(titleLabel, '.mat', '\_removePLI'));

[p2, f] = pwelch(data, hamming(nfft), [], nfft, 1/samplingInterval);
ax = axes('position', [margin*2+rightWidth, 2*margin+height, leftWidth, height]);
p2 = 10*log10(p2+2e-4);
plot_psd(f, p2, ax, nfft)

ax = axes('position', [margin, margin, rightWidth, height]);
plot_spectrogram(T, F, P2-P, ax, strrep(titleLabel, '.mat', '\_diff'));

ax = axes('position', [margin*2+rightWidth, margin, leftWidth, height]);
plot_psd(f, p2 - p, ax, nfft);

figureName = strrep(cscFile, '.mat', '.jpg');
saveas(gcf, figureName);


function [T, F, P] = get_psd(data, samplingInterval, flimits)
    fprintf('calculate PSD...\n');
    tic
    window = 30*(1/samplingInterval);
    [~,F,T,P]  = spectrogram(double(data), window, 0.8*window, (0.5:.2:flimits(2)), 1/samplingInterval, 'yaxis');
    P = P/max(max(P));
    P = (10*log10(abs(P+2e-4)))';
    P = [P(:,1) P P(:,end)];
    T = [0 T T(end)+1];
    P = imgaussfilt(P',3);
    toc
end

function plot_spectrogram(T, F, P, ax, titleLabel)
    imagesc(T,F,P); axis xy;
    xlimits = [0 T(end)];
    xticks = 1:(60*60)/2:T(end);
    for i = 1:length(xticks)
        xlabel_str{i} = sprintf('%.1f', xticks(i)/(60*60));
    end
    
    yticks = 0:5:F(end);
    axis([xlimits [0, F(end)]])
    set(ax,'xtick', xticks, 'XTickLabel', xlabel_str)
    colorbar
    axis([get(ax,'xlim'), [0.5, F(end)]])
    set(ax,'ytick', yticks)
    
    xlabelHandle = xlabel('t (hr)');
    % xlabelHandle.Position = [5, -2, 0];  
    ylabel('f (Hz)');
    title(titleLabel);
    set(findall(gcf,'-property','FontSize'),'FontSize', 10)
end

function plot_psd(F, P, ax, nfft)
    plot(ax, F, P, 'k', 'LineWidth', 1.2)
    xlabelHandle = xlabel('Freq (Hz)');
    % xlabelHandle.Position = [5, -2, 0];
    ylabel('Power (dB/Hz)')
    set(gca,'xscale','log')
    title(['PSD with nfft=' num2str(nfft)])
    set(findall(gcf,'-property','FontSize'), 'FontSize', 10)
end