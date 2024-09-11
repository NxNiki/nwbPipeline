function lfpTimestamps = downsampleTimestamps(microTimestampFiles, macroTimestampFiles, lfpFs, outputPath)

    [~, microTimestamps, ~, microTimestampStart] = combineCSC([], microTimestampFiles, inf);
    [~, macroTimestamps, ~, macroTimestampStart] = combineCSC([], macroTimestampFiles, inf);
    
    if microTimestampStart ~= macroTimestampStart
        warning("micro and macro channels have different start time!");
    end

    if microTimestamps(end) ~= macroTimestamps(end)
        warning("micro and macro channels have different duration: %f", microTimestamps(end) - macroTimestamps(end));
    end

    lfpTimestampsFileObj = matfile(fullfile(outputPath, "lfpTimestamps.mat"));
    lfpTimestampsFileObj.lfpTimestamps = [microTimestamps(1), 1/lfpFs, microTimestamps(end)];
    lfpTimestampsFileObj.microTimestampStart = microTimestampStart;
    lfpTimestampsFileObj.macroTimestampStart = macroTimestampStart;

    lfpTimestamps = microTimestamps(1): 1/lfpFs: microTimestamps(end);
    
end
