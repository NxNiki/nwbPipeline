function [startTime, endTime, createdTime, closedTime] = Nlx_getStartAndEndTimes(filename)

% Emily originally wrote this function to just look at headers, but it turns
% out that the time of file creation can often be quite far off from the 
% actual start of recording. So instead, we have to get the actual start
% and stop timestamps and then convert them to a date.

% Xin use datetime to convert posixtime to dt object.


startTime = NaT; endTime = NaT; createdTime = NaT; closedTime = NaT;

if ~exist(filename, 'file')
    warning('Nlx_getStartAndEndTimes: File not exists: %s', filename)
    return
end

[~,~, ext] = fileparts(filename);
switch ext
    case '.ncs'
        [timeStamps, header] = Nlx2MatCSC_v3(filename, [1 0 0 0 0],1, 1, []);
        startTime = datetime(timeStamps(1), 'ConvertFrom', 'posixtime');
        endTime = datetime(timeStamps(end), 'ConvertFrom', 'posixtime');
    case '.nev'
        [timeStamps, EventStrings, header] =...
            Nlx2MatEV_v3( filename, [1 0 0 0 1], 1,1, []);
        startEvent = cellfun(@(x)strcmp(x,'Starting Recording'), EventStrings);
        startTime = datetime(timeStamps(startEvent), 'ConvertFrom', 'posixtime');
        
        endEvent = cellfun(@(x)strcmp(x,'Stopping Recording'), EventStrings);
        endTime = datetime(timeStamps(endEvent), 'ConvertFrom', 'posixtime');
    otherwise
        warning('File type %s not currently supported by this function. Returning NaT', ext);
        return
end

timeCreated = regexp(header, '(?<=\-TimeCreated ).*', 'match', 'once');
empties = cellfun(@isempty, timeCreated);
createdTime = datetime(timeCreated{~empties}, InputFormat='yyyy/MM/dd HH:mm:ss');

timeClosed = regexp(header, '(?<=\-TimeClosed ).*', 'match', 'once');
empties = cellfun(@isempty, timeClosed);
closedTime = datetime(timeClosed{~empties}, InputFormat='yyyy/MM/dd HH:mm:ss');