function channelName = extractChannelName(filename, regPattern)
% extract channel name from raw csc .mat files.
% 'GA1-RA1_001.mat' -> 'GA1_RA1' with regPattern: '.*(?=_\d+)';

    if nargin < 2
        % just remove '.mat' by default:
        regPattern = '\w+(?=.mat)';
    end

    channelName = regexp(filename, regPattern, 'match', 'once');

    if isempty(channelName)
        channelName = filename;
    end
end