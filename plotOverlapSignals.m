function plotOverlapSignals(signal1, signal2, signal3, tsInterval)

transparency = 1;

% Plot the resampled signals
figure;
signalVal1 = signal1.value(signal1.ts>=tsInterval(1) & signal1.ts<=tsInterval(2));
signalTs1 = signal1.ts(signal1.ts>=tsInterval(1) & signal1.ts<=tsInterval(2));
plot(signalTs1, signalVal1, 'LineWidth', 1.5, 'LineStyle', '-', 'Color', [0.1, 0.7, 0.2, transparency]);

if ~isempty(signal2)
    signalVal2 = signal2.value(signal2.ts>=tsInterval(1) & signal2.ts<=tsInterval(2));
    signalTs2 = signal2.ts(signal2.ts>=tsInterval(1) & signal2.ts<=tsInterval(2));
    % Resample signal2 to match signalTs1
    signalVal2 = interp1(signalTs2, signalVal2, signalTs1);
    hold on;
    plot(signalTs1, signalVal2, 'LineWidth', 1.5, 'LineStyle', '-', 'Color', [0.7, 0.1, 0.2, transparency]);
    label2 = signal2.label;
else
    label2 = '';
end

if ~isempty(signal3)
    signalVal3 = signal3.value(signal3.ts>=tsInterval(1) & signal3.ts<=tsInterval(2));
    signalTs3 = signal3.ts(signal3.ts>=tsInterval(1) & signal3.ts<=tsInterval(2));
    % Resample signal2 to match signalTs1
    signalVal3 = interp1(signalTs3, signalVal3, signalTs1);
    hold on;
    plot(signalTs1, signalVal3, 'LineWidth', 1.5, 'LineStyle', '-', 'Color', [0.2, 0.1, 0.7, transparency]);
    label3 = signal3.label;
else
    label3 = '';
end

xlabel('Time');
ylabel('Amplitude');
legend(signal1.label, label2, label3);
title('');

end
