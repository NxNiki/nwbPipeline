
close all

x = [1, 2, 3, 4];
y = [2, 4, 6];
[R, lag] = xcorr(x, y, 'coeff');
stem(lag, R);
xlabel('Lag');
ylabel('Correlation Coefficient');
title('Cross-Correlation');

