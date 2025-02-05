function channelName = extractChannelName(filename, regPattern)
% extract channel name from raw csc .mat files.
% 'GA1-RA1_001.mat' -> 'GA1_RA1' with regPattern: '.*(?=_\d+)';

    if nargin < 2
        % remove post fix digits by default:
        regPattern = '\w+(?=_\d+)';
    end

    [~, filename] = fileparts(filename);

    channelName = regexp(filename, regPattern, 'match', 'once');

    if isempty(channelName)
        channelName = filename;
    end
end
