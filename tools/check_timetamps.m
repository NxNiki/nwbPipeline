% read a few raw .ncs data and calculate the average sampling rate:
% compare the block duration and other metrics of UCLA and iowa data.

close all

files = {
    '/Volumes/DATA/NLData/i677R/677-029_WatchPAT overnight/2023-03-26_19-56-50/CSC193_0002.ncs';
    '/Volumes/DATA/NLData/i728R/728-047_EEG_WatchPat_Overnight/2023-12-11_19-31-40/CSC193_0002.ncs';
    '/Volumes/DATA/NLData/i717R/717-052_EEG WatchPAT Overnight/2023-11-06_19-01-39/CSC193_0002.ncs';
    '/Volumes/DATA/NLData/D570/EXP5_Movie_24_Sleep/2024-01-27_00-01-35/GA3-RMH1_0003.ncs';
    '/Volumes/DATA/NLData/D571/EXP9_Movie_24_Sleep/2024-07-26_22-50-39/GA1-RAH8_0003.ncs';
    '/Volumes/DATA/NLData/D573/EXP9_Movie24_Sleep/2024-05-03_23-50-25/GA1-ROF7_0002.ncs';
    };


for i = 1:length(files)
    fprintf('%s.\n', files{i})
    [timeStamps, sampleFrequency, numSamples, signal] = readFile(files{i});

    [savedSR, actualSR] = getSR(timeStamps, sampleFrequency, numSamples);
    fprintf('saved SR: %.3f ', savedSR);
    fprintf('actual SR: %.3f\n', actualSR);

    [avgTsDiff, stdTsDiff, maxTsDiff, minTsDiff] = getTsDiffStats(timeStamps);
    fprintf('avgTsDiff: %.6f ', avgTsDiff);
    fprintf('stdTsDiff: %.9f ', stdTsDiff);
    fprintf('maxTsDiff: %.6f ', maxTsDiff);
    fprintf('minTsDiff: %.9f\n', minTsDiff);

    % hasOverLap = checkOverlap(signal');
    % fprintf('has OverLap Blocks: %s\n', string(hasOverLap));

    % checkConstantBlocks(signal', timeStamps, strrep(files{i}, '.ncs', '.png'));

    % checkConstantIntervals(signal, timeStamps, 5, strrep(files{i}, '.ncs', '_constantIntervals.png'));

    % checkNumberofValidSamples(numSamples, strrep(files{i}, '.ncs', '_numberOfSamples.png'));

    checkBlockDuration(timeStamps, strrep(files{i}, '.ncs', '_blockDuration.png'))

    disp('---')
end


function [timeStamps, sampleFrequency, numSamples, signal] = readFile(filename)

    FieldSelection(1) = 1;
    FieldSelection(2) = 1;
    FieldSelection(3) = 1;
    FieldSelection(4) = 1;
    FieldSelection(5) = 1;
    
    ExtractHeader = 1;
    ExtractMode = 1;
    ModeArray=[]; %all.
    
    [timeStamps, channelNumber, sampleFrequency, numSamples, signal, header] = Nlx2MatCSC_v3(filename, FieldSelection, ExtractHeader, ExtractMode, ModeArray);
    timeStamps = timeStamps * 1e-6; % convert timestamps to seconds.

end

function [savedSR, actualSR] = getSR(timeStamps, sampleFrequency, numSamples)

    savedSR = unique(sampleFrequency);
    tsStart = timeStamps(1);
    tsEnd = timeStamps(end) + numSamples(end) * 1/sampleFrequency(end);
    
    actualSR = sum(numSamples) / (tsEnd - tsStart);

end

function [avgTsDiff, stdTsDiff, maxTsDiff, minTsDiff] = getTsDiffStats(timeStamps)

    avgTsDiff = mean(diff(timeStamps));
    stdTsDiff = std(diff(timeStamps));
    maxTsDiff = max(diff(timeStamps));
    minTsDiff = min(diff(timeStamps));

end

function hasOverlap = checkOverlap(matrix)
    % Vectorized checkOverlap function to find if the end of each row
    % overlaps with the start of the next row
    % Input: matrix - an n by 512 matrix
    % Output: hasOverlap - a logical value indicating if there is overlap data

    numRows = size(matrix, 1);
    hasOverlap = false;
    nValues = 250:-1:5;

    for n = nValues
        endValues = matrix(1:numRows-1, end-n+1:end);
        startValues = matrix(2:numRows, 1:n);

        overlapIndex = find(all(endValues == startValues, 2) & all(startValues ~= startValues(:, 1), 2));
        if ~isempty(overlapIndex)
            hasOverlap = true;
            fprintf('overlap signal detected, overlap length: %d\n', n);
            fprintf('block of overlap (length: %d): \n', length(overlapIndex));
            disp(overlapIndex)
            return;
        end
    end
end

function checkConstantBlocks(data, timestamps, figName)

timestamps = timestamps - timestamps(1);
numPoints = size(data, 2);

constantBlocks = all(data == data(:, 1), 2);

if ~any(constantBlocks)
    return
end

constantData = data(constantBlocks, :);
timestamps = timestamps(constantBlocks);
% timestamps = timestamps / 60; % convert to minutes.

figure;
hold on; 

for i = 1:size(constantData, 1)
    start = (i - 1) * numPoints + 1; 
    stop = start + numPoints - 1; 

    plot(start:stop, constantData(i, :), 'LineStyle', '-', 'Color', 'b');
    if i == 1 || constantData(i, 1) ~= constantData(i-1, 1) 
        text(start, constantData(i, 1) + 10, num2str(timestamps(i)), 'VerticalAlignment', 'bottom');
    end
end

xlabel('Sample Points');
ylabel('Amplitude');
title(strrep(figName, '.png', ''));
hold off;

saveas(gcf, figName);

end


function checkConstantIntervals(data, timestamps, minLength, figName)

    timestamps = timestamps - timestamps(1);
    blockSize = min(size(data));
    data = data(:);
    n = length(data);
    dataChangeIdx = [1; find(diff(data)~=0)+1; n+1];
    runLengths = diff(dataChangeIdx);
    runLengthStartIndex = cumsum([1; runLengths(1:end-1)]);
    runLengthStartIndex = runLengthStartIndex(runLengths>=minLength);
    runLengths = runLengths(runLengths>=minLength);
    
    figure;
    hold on; 
    stop = 0;
    for i = 1:length(runLengths)
        start = stop + 1; 
        stop = start + runLengths(i) - 1; 
    
        plot(start:stop, data(runLengthStartIndex(i):runLengthStartIndex(i) + runLengths(i)-1), 'LineStyle', '-', 'Color', 'b');
        text(start, data(runLengthStartIndex(i)) - 1000 + (mod(i, 2)*2-1) * 2000, num2str(timestamps(floor(runLengthStartIndex(i)/blockSize) + 1)), 'VerticalAlignment', 'bottom');
    end
    
    xlabel('Sample Points');
    ylabel('Amplitude');
    title(strrep(figName, '.png', ''));
    hold off;
    
    saveas(gcf, figName);

end

function checkNumberofValidSamples(numSamples, figName)

    incompleteBlocks = sum(numSamples < 512);
    numBlocks = length(numSamples);
    msg = sprintf("%d missing blocks out of %d samples", incompleteBlocks, numBlocks);
    disp(msg);

    figure;
    set(gcf, 'Position', [100, 100, 1200, 600]);
    plot(numSamples)
    xlabel('Sample Points');
    ylabel('number of samples');
    text(floor(numBlocks/2), 500, msg, 'FontSize', 15)
    title(strrep(figName, '.png', ''));
    hold off;
    
    saveas(gcf, figName);
    
end

function checkBlockDuration(timeStamps, figName)

    threshold = 0.3125; % milliseconds
    blockDuration = diff(timeStamps);
    m = median(blockDuration);

    numShortBlocks = sum(blockDuration < m - threshold * 1e-3);
    numLongBlocks = sum(blockDuration > m + threshold * 1e-3);

    msg = sprintf("median block duration: %f, %d short blocks, %d long blocks", m, numShortBlocks, numLongBlocks);
    disp(msg);

    figure;
    set(gcf, 'Position', [100, 100, 1200, 600]);
    plot(blockDuration)
    hold on
    yline(m - threshold * 1e-3, '--', 'LineWidth', 1.5);
    yline(m + threshold * 1e-3, '--', 'LineWidth', 1.5);
    xlabel('Sample Points');
    ylabel('block duration');
    text(floor(length(blockDuration)/2), max(blockDuration), msg, 'FontSize', 15)
    title(strrep(figName, '.png', ''));
    hold off;
    
    saveas(gcf, figName);

end


