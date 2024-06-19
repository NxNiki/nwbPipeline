function channelName = extractChannelName(filename, regPattern)

    if nargin < 2
        % just remove '.mat' by default:
        regPattern = '\w+(?=.mat)';
    end
    match = regexp(filename, regPattern, 'match');
    channelName = match{1};
end