function [ccf, tvec] = plot_cross_correlogram(ts1, ts2, tsLabel1, tsLabel2)
% function [ccf,tvec] = ccf(cfg,ts1,ts2)
%
% estimate crosscorrelation of input spike trains
%
% INPUTS:
% ts1: vector of spike times (in s), [nSpikes x 1]
% ts2: vector of spike times (in s), [nSpikes x 1]
%
% cfg_def.binsize = 0.001; % ccf bin size in s
% cfg_def.max_t = 0.5; % length of ccf in s
% cfg_def.smooth = 0; % set to 1 to smooth
% cfg_def.gauss_w = 1; % width of Gaussian convolution window (in s)
% cfg_def.gauss_sd = 0.02; % SD of Gaussian convolution window (in s)
% cfg_def.xcorr = 'coeff'; % method to compute SDF xcorr
%test_xc
% OUTPUTS:
% ccf: autocorrelation estimate (distribution of ts1 relative to ts2)
% tvec: bin centers (in s)
%
% MvdM 2015-01-29 initial version
%
% TODO: implement version that runs on ts input (ccfs between all cells)

cfg = [];
cfg.binsize = 0.001;
cfg.max_t = 0.05;
cfg.smooth = 0; % set to 1 to compute ccf on SDF, 0 for raw spikes
cfg.gauss_w = 1; % width of Gaussian convolution window (in s)
cfg.gauss_sd = 0.02; % SD of Gaussian convolution window (in s)
cfg.xcorr = 'coeff'; % method to compute SDF xcorr

% guarantee vectoricity
if ~isempty(ts1), ts1 = ts1(:); end
if ~isempty(ts2), ts2 = ts2(:); end

% construct timebase for binarized spike trains
tbin_edges = min(cat(1,ts1,ts2)):cfg.binsize:max(cat(1,ts1,ts2));

% binarize spike trains
ts1_sdf = histc(ts1,tbin_edges); ts1_sdf = ts1_sdf(1:end-1);
ts2_sdf = histc(ts2,tbin_edges); ts2_sdf = ts2_sdf(1:end-1);

if cfg.smooth % SDF (spike density function) version
    % convolve with kernel
    gauss_window = cfg.gauss_w./cfg.binsize; % 1 second window
    gauss_SD = cfg.gauss_sd./cfg.binsize; % 0.02 seconds (20ms) SD
    gk = gausskernel(gauss_window,gauss_SD); gk = gk./cfg.binsize; % normalize by binsize
    ts1_sdf = conv2(ts1_sdf, gk, 'same'); % convolve with gaussian window
    ts2_sdf = conv2(ts2_sdf, gk, 'same'); % convolve with gaussian window
end

[ccf, tvec] = xcorr(ts1_sdf, ts2_sdf, cfg.max_t./cfg.binsize, cfg.xcorr);
tvec = tvec.*cfg.binsize;

% Plot the cross-correlogram
figure;
bar(tvec, ccf, 'k', 'EdgeColor', 'none'); % bar plot for cross-correlogram
xlabel('Time Lag (s)');
ylabel('Cross-Correlation');
title(sprintf('Cross-Correlogram: cluster %d vs %d, resolution: %.3f ms', tsLabel1, tsLabel2, cfg.binsize * 1000));
grid on;
    
end