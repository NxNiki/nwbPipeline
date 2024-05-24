function outputFiles = getSpikeCodes(spikeFiles, outputPath, skipExist)

makeOutputPath(spikeFiles, outputPath, skipExist)

hasSpikes = cell(length(spikeFiles), 1);
hasSpikesPrecise = cell(length(spikeFiles), 1);
outputFiles = cell(length(spikeFiles), 1);

% calculate spikeCodes:
parfor fnum = 1:length(spikeFiles)

    spikeFile = spikeFiles{fnum};
    [~, filename, ext] = fileparts(spikeFile);
    outFile = [strrep(filename, '_spikes', '_spikeCodesTemp'), ext];
    tmpOutFile = ['temp_', outFile];
    outputFiles{fnum} = outFile;

    outFile = fullfile(outputPath, outFile);
    tmpOutFile = fullfile(outputPath, tmpOutFile);

    fprintf('get spike codes:\n %s\n', outFile);

    spikeFileObj = matfile(spikeFile, 'Writable', false);
    param = spikeFileObj.param;
    outputStruct = spikeFileObj.outputStruct;
    spikeTimestamps = spikeFileObj.spikeTimestamps;
    duration = spikeFileObj.duration;
    spikes = spikeFileObj.spikes;
    
    % get spike codes to run clustering:
    [spikeCodes, spikeHist, spikeHistPrecise] = computeSpikeCodes(spikes, spikeTimestamps, duration, param, outputStruct);

    if exist(tmpOutFile, "file")
        delete(tmpOutFile);
    end

    hasSpikes{fnum} = spikeHist;
    hasSpikesPrecise{fnum} = spikeHistPrecise;

    fprintf('write spike codes to file:\n %s\n', outFile);
    matobj = matfile(tmpOutFile, 'Writable', true);
    matobj.spikeHist = spikeHist;
    matobj.spikeHistPrecise = spikeHistPrecise;
    matobj.timestampsStart = timestampsStart;
    matobj.spikeCodes = spikeCodes;

    movefile(tmpOutFile, outFile);

end

hasSpikes = [hasSpikes{:}];
hasSpikesPrecise = [hasSpikesPrecise{:}];
percentConcurrentSpikes = sum(hasSpikes)/length(spikeFiles);
percentConcurrentSpikesPrecise = sum(hasSpikesPrecise);

% get across channel spike codes:
parfor fnum = 1:length(outputFiles)
    
    spikeCodeFile = outputFiles{fnum};
    outFile = strrep(spikeCodeFile, '_spikeCodesTemp', '_spikeCodes');
    tempOutFile = fullfile(outputPath, strrep(outFile, 'temp_', ''));
    
    outFile = fullfile(outputPath, outFile);
    fprintf('get across channel spike codes:\n %s\n', outFile);
    spikeCodeFileObj = matfile(spikeCodeFile, 'Writable', false);
    spikeCodes = spikeCodeFileObj.spikeCodes;

    spikeFileObj = matfile(spikeFiles{fnum}, 'Writable', false);
    duration = spikeFileObj.duration;
    spikeTimestamps = spikeFileObj.spikeTimestamps;

    binEdges = 0:3:1000*(duration)+3;
    binEdgesPrecise = 0:2000/sr:1000*duration+1;
    

    bin = discretize(spikeTimestamps, binEdges);
    fractionConcurrent = percentConcurrentSpikes(bin);
    spikeCodes = [spikeCodes, table(fractionConcurrent(:), 'VariableNames', {'fractionConcurrent'})];

    binPrecise = discretize(spikeTimestamps, binEdgesPrecise);
    fractionConcurrentPrecise = percentConcurrentSpikesPrecise(binPrecise);
    spikeCodes = [spikeCodes, table(fractionConcurrentPrecise(:), 'VariableNames', {'fractionConcurrentPrecise'})];

    fprintf('write spike codes to file:\n %s\n', outFile);
    matobj = matfile(tempOutFile, 'Writable', true);
    matobj.spikeCodes = spikeCodes;
    matobj.spikeHist = spikeFileObj.spikeHist;
    matobj.spikeHistPrecise = spikeFileObj.spikeHistPrecise;
    matobj.timestampsStart = spikeFileObj.timestampsStart;

    movefile(tempOutFile, outFile);
    delete(fullfile(outputPath, spikeCodeFile));
    outputFiles{fnum} = outFile;

end

