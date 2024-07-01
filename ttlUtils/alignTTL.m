function [ttlLogAlign, ttlCodeAlign, tsAlign] = alignTTL(ttlLog, ttlCode, ts)

% THIS IS OLD SOLUTION, USE LONGESTCOMMONSEQUENCE.M TO ALIGNTTL.

% ttlLog: cell array with columns: ts, ttl message, ttl code.
% ttlCode: index ranging from 1 to 100
% this function match ttlLog and ttlCode based on ttlcode and timestamps.
% if there are multiple ttlLog files, concantenate them vertically.

% TTL is a signal that marks the events during the experiment.
% It is sent from the Mac/PC to the recording device.
% If the experiment pauses on the Mac/PC, A new TTL log is created.
% So we have multiple TTL logs on the Mac/PC (ttlLog), 
% but only one on the recording machine (ttlCode)
% testing TTLs are also not saved on ttlCode at the beginning. But it can
% be save if a new experiment start. So far we only remove the testing TTLs
% at the beginning of the first TTLlog.


ttlLogCode = cell2mat(ttlLog(:, 3));
ttlLogIdx = [];
ttlCodeIdx = [];
helper(1, 1);

ttlLogAlign = ttlLog(ttlLogIdx, :);
ttlCodeAlign = ttlCode(ttlCodeIdx);
tsAlign = ts(ttlCodeIdx);


    function helper(logStartIdx, codeStartIdx)
        RemainingLength = min(length(ttlLogCode) - logStartIdx, length(ttlCode) - codeStartIdx) + 1;
        
        if RemainingLength <= 0
            return
        end

        firstMatchIdx = find(ttlLogCode(logStartIdx:end) == ttlCode(codeStartIdx), 1, 'first');
        firstMatchIdx = firstMatchIdx + logStartIdx - 1;

        RemainingLength = RemainingLength - firstMatchIdx;
        firstMismatchIdx = find(ttlLogCode(firstMatchIdx: firstMatchIdx + RemainingLength - 1) ~= ttlCode(codeStartIdx: codeStartIdx + RemainingLength - 1), 1, "first");

        if firstMismatchIdx > 1
            ttlLogIdx = [ttlLogIdx, firstMatchIdx: firstMatchIdx + firstMismatchIdx - 1];
            ttlCodeIdx = [ttlCodeIdx, codeStartIdx: codeStartIdx + firstMismatchIdx - 1];
        elseif isempty(firstMismatchIdx)
            ttlLogIdx = [ttlLogIdx, firstMatchIdx: firstMatchIdx + RemainingLength - 1];
            ttlCodeIdx = [ttlCodeIdx, codeStartIdx: codeStartIdx + RemainingLength - 1];
            return
        end

        helper(firstMatchIdx + firstMismatchIdx, codeStartIdx + firstMismatchIdx)
    end

end




