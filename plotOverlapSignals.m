function plotOverlapSignals(signal1, signal2, signal3, tsInterval, ylimit, titleName)

if nargin < 5
    ylimit = [];
end

transparency = .5;
downsampleRate = 10;


% Plot the resampled signals
figure;
signalVal1 = signal1.value(signal1.ts>=tsInterval(1) & signal1.ts<=tsInterval(2));
signalTs1 = signal1.ts(signal1.ts>=tsInterval(1) & signal1.ts<=tsInterval(2));

plot(signalTs1(1:downsampleRate:end), signalVal1(1:downsampleRate:end), 'LineWidth', .7, 'LineStyle', '-', 'Color', [0.1, 0.7, 0.2, .9]);
legendLabels = {signal1.label};

if ~isempty(signal2)
    signalVal2 = signal2.value(signal2.ts>=tsInterval(1) & signal2.ts<=tsInterval(2));
    signalTs2 = signal2.ts(signal2.ts>=tsInterval(1) & signal2.ts<=tsInterval(2));
    % Resample signal2 to match signalTs1
    signalVal2 = interp1(signalTs2, signalVal2, signalTs1);
    hold on;
    plot(signalTs1(1:downsampleRate:end), signalVal2(1:downsampleRate:end), 'LineWidth', .6, 'LineStyle', '-', 'Color', [0.7, 0.1, 0.2, transparency]);
    legendLabels = [legendLabels, {signal2.label}];
end

if ~isempty(signal3)
    signalVal3 = signal3.value(signal3.ts>=tsInterval(1) & signal3.ts<=tsInterval(2));
    signalTs3 = signal3.ts(signal3.ts>=tsInterval(1) & signal3.ts<=tsInterval(2));
    % Resample signal2 to match signalTs1
    signalVal3 = interp1(signalTs3, signalVal3, signalTs1);
    hold on;
    plot(signalTs1(1:downsampleRate:end), signalVal3(1:downsampleRate:end), 'LineWidth', .6, 'LineStyle', '-', 'Color', [0.2, 0.1, 0.7, transparency]);
    legendLabels = [legendLabels, {signal3.label}];
end

xlabel('Time (sec)');
ylabel('Amplitude');
if ~isempty(ylimit)
    ylim(ylimit);
end
legend(legendLabels);

title(strrep(titleName, '_', ' '), 'FontSize', 16);

end
