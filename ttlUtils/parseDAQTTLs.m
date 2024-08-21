function TTLs = parseDAQTTLs(eventsFile, ttlLogFiles, ttlSavePath)
% timestamps in event file should be converted to seconds.
% ttlCode is the TTL neuralyn received
% ttlLog is the TTL experiment DEVICE send.

if nargin < 3
    ttlSavePath = ['TTLLog-', datetime('now', 'Format', 'yyyy-MM-dd_HH:mm:ss')];
end

if ~iscell(ttlLogFiles)
    ttlLogFiles = {ttlLogFiles};
end
eventsFileObj = matfile(eventsFile, "Writable", false);
ts = eventsFileObj.timestamps;
ttlCode = eventsFileObj.TTLs;

inds = ttlCode==0 | ttlCode > 100;
ts(inds) = [];
ttlCode(inds) = [];
ttlCode = ttlCode(:);
ts = ts(:);

ttlLog = [];
for i = 1: length(ttlLogFiles)
    ttlLogFileObj = matfile(ttlLogFiles{i});
    ttlLog = [ttlLog; ttlLogFileObj.ttlLog];
end

if ~isequal(cell2mat(ttlLog(:,3)), ttlCode(:))
    [ttlLog, ts] = realignTTLs(ttlLog, ts, ttlCode, ttlSavePath);
end

% we want time stamps from Neuralynx and strings from the TTL log
TTLs = arrayfun(@(x)x, ts, 'uniformoutput', 0);
TTLs(:,2) = cellfun(@(x)x, ttlLog(:,2), 'uniformoutput', 0);

save(fullfile(ttlSavePath, 'TTLs.mat'), 'TTLs');

end

function [ttlLogAlign,tsAlign] = realignTTLs(ttlLog, ts, ttlCode, ttlSavePath)

warning('realign ttlLog and ttlCode');

% remove test ttl at the begining of ttlLog:
ttlLogTs = cell2mat(ttlLog(:, 1));
testTTLIdx = find(ttlLogTs == 0);
lastTestIdx = find(testTTLIdx <= 5, 1, 'last');
ttlLog(1:lastTestIdx, :) = [];

% [ttlCode, ts] = cleanTTLCode(ttlCode, ts);
badIdx = findBadIndices(ttlCode);
ttlCode(badIdx) = [];
ts(badIdx) = [];

% some times the recording starts later than the experiment PC, leads to
% missing ttls at the beginning of ttlCode. We fill the missing values
% according to ttlCode in ttlLog.
[ttlCode, ts, ttlLog] = fillMissingCode(ttlCode, ts, ttlLog);

% in most case we are good here but if we have multiple ttlLogs or there
% are mismatch ttlCode, run this to find the longest common sequence.
[idx1, idx2] = longestCommonSubsequence(cell2mat(ttlLog(:, 3)), ttlCode);
ttlLogAlign = ttlLog(idx1, :);
ttlCodeAlign = ttlCode(idx2, :);
tsAlign = ts(idx2, :);

% Create a new figure
fig = figure;

% Plot 1
subplot(2, 2, [1, 2]);
plot(ttlCodeAlign);
hold on;
plot(cell2mat(ttlLogAlign(:, 3)), 'r--');
title('Plot 1: TTL Code Align');

% Plot 2
subplot(2, 2, 3);
tsEvent = tsAlign - tsAlign(1) + ttlLogAlign{1, 1};
plot(tsEvent, 'r--');
hold on;
plot(cell2mat(ttlLogAlign(:, 1)), 'Color', [.2, .1, .9, .7], 'LineWidth', 1);
r = corr(tsEvent, cell2mat(ttlLogAlign(:, 1)));
title(sprintf('Timestamp: r = %0.3f', r));

% Plot 3
subplot(2, 2, 4);
ts1diff = diff(tsAlign);
ts2diff = diff(cell2mat(ttlLogAlign(:, 1)));

idx1 = isoutlier(ts1diff, 'quartiles');
idx2 = isoutlier(ts2diff, 'quartiles');

plot(ts1diff(~idx1 & ~idx2), ts2diff(~idx1 & ~idx2), '.');
r = corr(ts1diff(~idx1 & ~idx2), ts2diff(~idx1 & ~idx2));
title(sprintf('Timestamp Difference: r = %0.3f (Outliers Removed)', r));

% Save the figure to a specified path
saveas(fig, fullfile(ttlSavePath, 'TTLAlignment.png'));


while any(cell2mat(ttlLogAlign(:, 3)) ~= ttlCodeAlign)
    msgbox('TTL code not aligned! You need to fix it manually and continue', 'Warning', 'warn');
    keyboard
end

end

function [ttlCode, ts] = cleanTTLCode(ttlCode, ts)
% Emily's code to remove unexpected ttlCode. This should be identical to
% Chris's code (findBadIndices).

    nlx_ts = ts-ts(1);
    nlx_code = ttlCode;
    % log_ts = cell2mat(ttlLog(:,1))-ttlLog{1};
    % log_code = cell2mat(ttlLog(:,3));

    counter = 1;
    while counter < length(nlx_ts)
        if (nlx_code(counter+1)-nlx_code(counter) ~= 1) && ...
                (nlx_code(counter)~= 100 || nlx_code(counter+1)~=1)
            nlx_code(counter+1) = [];
            nlx_ts(counter+1) = [];
        else
            counter = counter+1;
        end
    end

    ts = nlx_ts+ts(1);
    ttlCode = nlx_code;
end

function bad_indices = findBadIndices(arr)
    % Initialize an empty array to store the indices of bad elements
    bad_indices = [];

    % Initialize the last correct value as the first element in the array
    last_correct_value = arr(1);

    % Iterate through the array starting from the second element
    for i = 2:length(arr)
        % Calculate expected next value (wrap around from 100 to 1)
        expected_next_value = mod(last_correct_value, 100) + 1;

        % Check if current element matches the expected next value
        if arr(i) == expected_next_value
            % Update the last correct value
            last_correct_value = arr(i);
        else
            % If it does not match, record the index as a bad index
            bad_indices(end + 1) = i;
        end
    end
end

function [ttlCode, ts, ttlLog] = fillMissingCode(ttlCode, ts, ttlLog)
    % fill missing code in ttlCode and ts at the beginning:

    if length(ttlCode) >= size(ttlLog, 2)
        return
    end

    % if ttlLog is longer or equal to ttlCode (this may due to failure in
    % sending TTL from ttlLog to ttlCode), we may need to recover the
    % ttlCode
    ttlLogCode = cell2mat(ttlLog(:, 3));
    lastMatchIdx = find(ttlLogCode == ttlCode(end), 1, 'last');
    ttlLog(lastMatchIdx+1:end, :) = [];
    ttlLogCode(lastMatchIdx+1:end) = [];
    ttlLogTs = cell2mat(ttlLog(:, 1));

    numMissing = length(ttlLogCode) - length(ttlCode);

    % add missing TTL to ttlcode and ts:
    if numMissing > 0 && all(ttlLogCode(numMissing+1:end) == ttlCode)
        ttlCode = [ttlLogCode(1:numMissing); ttlCode];
        ts = [repmat(ts(1), numMissing, 1); ts];

        tsDiff = ttlLogTs(numMissing+1) - ttlLogTs(1:numMissing);
        ts(1:numMissing) = ts(1:numMissing) - tsDiff;
    end
end
