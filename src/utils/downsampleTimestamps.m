function lfpTimestamps = downsampleTimestamps(microTimestampFiles, macroTimestampFiles, lfpFs, outputPath)

    [~, microTimestamps, ~, microTimestampStart] = combineCSC([], microTimestampFiles, inf);
    [~, macroTimestamps, ~, macroTimestampStart] = combineCSC([], macroTimestampFiles, inf);

    if microTimestampStart ~= macroTimestampStart
        warning("micro and macro channels have different start time!");
    end

    if microTimestamps(end) ~= macroTimestamps(end)
        warning("micro and macro channels have different duration: %f", microTimestamps(end) - macroTimestamps(end));
    end

    lfpTsFileName = fullfile(outputPath, "lfpTimestamps.mat");
    lfpTsFileNameTemp = strrep(lfpTsFileName, '.mat', '_temp.mat');

    if exist(lfpTsFileNameTemp, "file")
        delete(lfpTsFileNameTemp);
    end

    lfpTimestampsFileObj = matfile(lfpTsFileNameTemp);
    lfpTimestampsFileObj.lfpTimestamps = [microTimestamps(1), 1/lfpFs, microTimestamps(end)];
    lfpTimestampsFileObj.microTimestampStart = microTimestampStart;
    lfpTimestampsFileObj.macroTimestampStart = macroTimestampStart;

    movefile(lfpTsFileNameTemp, lfpTsFileName);

    lfpTimestamps = microTimestamps(1): 1/lfpFs: microTimestamps(end);

end
