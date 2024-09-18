% test Nlx_readCSC.m


fileName = 'neuralynx/raw/GA1-RAH1.ncs';
logPath = 'neuralynx/CSC_micro/log_file';

[signal, ADBitVolts, computedTimeStamps, samplingInterval, channelNumber] = Nlx_readCSC(fileName, 1, logPath);
