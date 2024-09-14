% test combineCSC.m

% unfinished...

signalFiles = {

    };

timestampsFiles = {
    };

useSinglePrecision = true;
maxGapDuration = inf;

[signal, timestamps, samplingIntervalDuration, timestampsStart] = combineCSC(signalFiles, timestampsFiles, maxGapDuration, useSinglePrecision);
