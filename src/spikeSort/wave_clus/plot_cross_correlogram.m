function plot_cross_correlogram(ts1, ts2, tsLabel1, tsLabel2)
% function plot_cross_correlogram_ui(ts1, ts2, tsLabel1, tsLabel2)
%
% Creates a UI to adjust cfg parameters and plot the cross-correlogram.
%
% INPUTS:
% ts1, ts2: vectors of spike times (in seconds)
% tsLabel1, tsLabel2: labels for the spike time series

% Default configuration
cfg.binsize = 0.001;
cfg.max_t = 0.05;
cfg.smooth = 0;
cfg.gauss_w = 1;
cfg.gauss_sd = 0.02;
cfg.xcorr = 'coeff';

% Create the UI figure
fig = figure('Name', 'Cross-Correlogram Parameters', 'Position', [100, 100, 900, 600]);

text_width = .15;
edit_width = .10;
% Create UI components using normalized units
uicontrol('Style', 'text', 'Units', 'normalized', ...
    'Position', [0.05, 0.83, text_width, 0.04], 'String', 'Bin Size (s):', 'HorizontalAlignment', 'left');
binsizeInput = uicontrol('Style', 'edit', 'Units', 'normalized', ...
    'Position', [0.25, 0.83, edit_width, 0.04], 'String', cfg.binsize);

uicontrol('Style', 'text', 'Units', 'normalized', ...
    'Position', [0.05, 0.76, text_width, 0.04], 'String', 'Max Time (s):', 'HorizontalAlignment', 'left');
maxTInput = uicontrol('Style', 'edit', 'Units', 'normalized', ...
    'Position', [0.25, 0.76, edit_width, 0.04], 'String', cfg.max_t);

uicontrol('Style', 'text', 'Units', 'normalized', ...
    'Position', [0.05, 0.69, text_width, 0.04], 'String', 'Smooth:', 'HorizontalAlignment', 'left');
smoothInput = uicontrol('Style', 'checkbox', 'Units', 'normalized', ...
    'Position', [0.25, 0.69, edit_width, 0.04], 'Value', cfg.smooth);

uicontrol('Style', 'text', 'Units', 'normalized', ...
    'Position', [0.05, 0.62, text_width, 0.04], 'String', 'Gaussian Window Width (s):', 'HorizontalAlignment', 'left');
gaussWInput = uicontrol('Style', 'edit', 'Units', 'normalized', ...
    'Position', [0.25, 0.62, edit_width, 0.04], 'String', cfg.gauss_w);

uicontrol('Style', 'text', 'Units', 'normalized', ...
    'Position', [0.05, 0.55, text_width, 0.04], 'String', 'Gaussian Window SD (s):', 'HorizontalAlignment', 'left');
gaussSDInput = uicontrol('Style', 'edit', 'Units', 'normalized', ...
    'Position', [0.25, 0.55, edit_width, 0.04], 'String', cfg.gauss_sd);

uicontrol('Style', 'text', 'Units', 'normalized', ...
    'Position', [0.05, 0.48, text_width, 0.04], 'String', 'XCorr Method:', 'HorizontalAlignment', 'left');
xcorrInput = uicontrol('Style', 'edit', 'Units', 'normalized', ...
    'Position', [0.25, 0.48, edit_width, 0.04], 'String', cfg.xcorr);

% Axes for plotting
axesPlot = axes('Parent', fig, 'Units', 'normalized', ...
    'Position', [0.45, 0.33, 0.45, 0.5]);

% Plot button
uicontrol('Style', 'pushbutton', 'Units', 'normalized', ...
    'Position', [0.15, 0.35, 0.12, 0.05], 'String', 'Plot', ...
    'Callback', @plotButtonCallback);

% Disable Gaussian parameters if smooth is unchecked
set(smoothInput, 'Callback', @toggleGaussianFields);

% Callback for the Plot button
function plotButtonCallback(~, ~)
    % Update cfg with current UI values
    cfg.binsize = str2double(get(binsizeInput, 'String'));
    cfg.max_t = str2double(get(maxTInput, 'String'));
    cfg.smooth = get(smoothInput, 'Value');
    cfg.gauss_w = str2double(get(gaussWInput, 'String'));
    cfg.gauss_sd = str2double(get(gaussSDInput, 'String'));
    cfg.xcorr = get(xcorrInput, 'String');

    % Guarantee vectoricity
    if ~isempty(ts1), ts1 = ts1(:); end
    if ~isempty(ts2), ts2 = ts2(:); end

    % Construct timebase for binarized spike trains
    tbin_edges = min(cat(1, ts1, ts2)):cfg.binsize:max(cat(1, ts1, ts2));

    % Binarize spike trains
    ts1_sdf = histc(ts1, tbin_edges); ts1_sdf = ts1_sdf(1:end-1);
    ts2_sdf = histc(ts2, tbin_edges); ts2_sdf = ts2_sdf(1:end-1);

    if cfg.smooth % SDF (spike density function) version
        gauss_window = cfg.gauss_w / cfg.binsize;
        gauss_SD = cfg.gauss_sd / cfg.binsize;
        gk = gausskernel(gauss_window, gauss_SD); gk = gk / cfg.binsize;
        ts1_sdf = conv(ts1_sdf, gk, 'same');
        ts2_sdf = conv(ts2_sdf, gk, 'same');
    end

    [ccf, tvec] = xcorr(ts1_sdf, ts2_sdf, cfg.max_t / cfg.binsize, cfg.xcorr);
    tvec = tvec * cfg.binsize;

    % Plot the cross-correlogram in the UI
    cla(axesPlot); % Clear the axes
    bar(axesPlot, tvec, ccf, 'k', 'EdgeColor', 'none'); % Bar plot for cross-correlogram
    hold(axesPlot, 'on');
    xline(axesPlot, 0.003, '--r', 'LineWidth', 1.5);
    xline(axesPlot, -0.003, '--r', 'LineWidth', 1.5);
    hold(axesPlot, 'off');
    xlabel(axesPlot, 'Time Lag (s)');
    ylabel(axesPlot, 'Cross-Correlation');
    title(axesPlot, sprintf('Cross-Correlogram: cluster %d vs %d, binsize: %.3f ms', tsLabel1, tsLabel2, cfg.binsize * 1000));
    grid(axesPlot, 'on');
end

% Toggle Gaussian fields based on Smooth value
function toggleGaussianFields(~, ~)
    if get(smoothInput, 'Value') == 0
        set(gaussWInput, 'Enable', 'off');
        set(gaussSDInput, 'Enable', 'off');
    else
        set(gaussWInput, 'Enable', 'on');
        set(gaussSDInput, 'Enable', 'on');
    end
end

% Initialize Gaussian fields and plot on start
toggleGaussianFields();
plotButtonCallback();

end
