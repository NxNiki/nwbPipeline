function TTLs = parseDAQTTLs(eventsFile, ttlLogFile, ttlSavePath)
% timestamps in event file should be converted to seconds.
% ttlCode is the TTL neuralyn received
% ttlLog is the TTL experiment device send.


eventsFileObj = matfile(eventsFile, "Writable", false);
ts = eventsFileObj.timestamps;
ttlCode = eventsFileObj.TTLs;

inds = ttlCode==0 | ttlCode > 100;
ts(inds) = [];
ttlCode(inds) = [];
ttlCode = ttlCode(:);
ts = ts(:);

ttlLogFileObj = matfile(ttlLogFile);
ttlLog = ttlLogFileObj.ttlLog;

if ~isequal(cell2mat(ttlLog(:,3)), ttlCode(:))
    [ttlLog, ts] = realignTTLs(ttlLog, ts, ttlCode);
end

% we want time stamps from Neuralynx and strings from the TTL log
TTLs = arrayfun(@(x)x, ts, 'uniformoutput', 0);
TTLs(:,2) = cellfun(@(x)x, ttlLog(:,2), 'uniformoutput', 0);

if exist('ttlSavePath','var') && ~isempty(ttlSavePath)
    save(ttlSavePath, 'TTLs');
end
end

function [ttlLogAlign,tsAlign] = realignTTLs(ttlLog, ts, ttlCode)

warning('This isn''t implemented yet. Please write it, or just realign your TTLs yourself...');
disp('Please align such that ttlLog, ts, and ttlCode are the same length (and ttlLog(:,3) is equal to ttlCode), and then type ''return''');
disp('If there are multiple TTL log files, load all and concantencate them by: ttlLog1 = [ttlLog1; ttlLog] and then continue.')

ttlLog1 = ttlLog;
keyboard
ttlLog = ttlLog1;

% load additional ttl log files and run:
% ttlLog = [ttlLog1; ttlLog];

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

figure;
plot(ttlCodeAlign);
hold on
plot(cell2mat(ttlLogAlign(:, 3)), 'r--');

figure;
tsEvent = tsAlign - tsAlign(1) + ttlLogAlign{1, 1};
plot(tsEvent, 'r--');
hold on
plot(cell2mat(ttlLogAlign(:, 1)), 'Color', [.2, .1, .9, .7], 'LineWidth', 1);
r = corr(tsEvent, cell2mat(ttlLogAlign(:, 1)));
title(sprintf('timestamp: r = %0.3f', r))

figure
ts1diff = diff(tsAlign);
ts2diff = diff(cell2mat(ttlLogAlign(:, 1)));

idx1 = isoutlier(ts1diff, 'quartiles');
idx2 = isoutlier(ts2diff, 'quartiles');

plot(ts1diff(~idx1 & ~idx2), ts2diff(~idx1 & ~idx2), '.');
r = corr(ts1diff(~idx1 & ~idx2), ts2diff(~idx1 & ~idx2));
title(sprintf('timestamp difference: r = %0.3f (outlier removed)', r));

while any(cell2mat(ttlLogAlign(:, 3)) ~= ttlCodeAlign)
    msgbox('TTL code not aligned!', 'Warning', 'warn');
end
keyboard
close all

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



