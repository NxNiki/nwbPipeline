clear
close

%% create ts at 32k hz:
samplingInterval = 1/32000;
ts32k = 0: samplingInterval: 300;

% downsample ts at 20k hz
Fs = 2000;
ts2k = linearizeTimestamps(ts32k, Fs);

% check difference in ts:
df1 = unique(diff(ts2k))

%% create ts at 32k hz with multiple segments:
samplingInterval = 1/32000;
ts32k = [0: samplingInterval: 100, 101: samplingInterval: 200, 205: samplingInterval: 300];

% downsample ts at 20k hz
Fs = 2000;
ts2k = linearizeTimestamps(ts32k, Fs);

% check difference in ts:
df2 = unique(diff(ts2k))

%% load timestamps for different experiments:
tsObj1 = matfile('lfpTimeStamps_macro_exp001.mat');
tsObj2 = matfile('lfpTimeStamps_macro_exp002.mat');
tsMacro = [tsObj1.timeStamps, tsObj2.timeStamps];
% downsample ts at 20k hz
Fs = 2000;
ts2k = linearizeTimestamps(tsMacro(:), Fs);

% check difference in ts:
df3 = unique(diff(ts2k))


%% load timestamps with multiple segments:

tsObj1 = matfile('lfpTimeStamps_macro_seg004.mat');
tsObj2 = matfile('lfpTimeStamps_macro_seg005.mat');
tsMacro = [tsObj1.timeStamps, tsObj2.timeStamps];
% downsample ts at 20k hz
Fs = 2000;
ts2k = linearizeTimestamps(tsMacro(:), Fs);

% check difference in ts:
df4 = unique(diff(ts2k))

%% plot result:
subplot(3, 1, 1)
plot(df1, '*')
subplot(3, 1, 2)
plot(df2, '*')
set(gca, 'YScale', 'log');
subplot(3, 1, 3)
plot(df3, '*')
set(gca, 'YScale', 'log');


end