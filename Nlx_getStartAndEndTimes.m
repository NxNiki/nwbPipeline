function [startTime, endTime, createdTime, closedTime] = Nlx_getStartAndEndTimes(filename)

% Emily originally wrote this function to just look at headers, but it turns
% out that the time of file creation can often be quite far off from the 
% actual start of recording. So instead, we have to get the actual start
% and stop timestamps and then convert them to a date.

% Xin use datetime to convert posixtime to dt object.

[~,~, ext] = fileparts(filename);
switch ext
    case '.ncs'
        [timeStamps, header] = Nlx2MatCSC_v3(filename, [1 0 0 0 0],1, 1, []);
        startTime = timeStamps(1);
        endTime = timeStamps(end);
    case '.nev'
        [timeStamps, EventStrings, header] =...
            Nlx2MatEV_v3( filename, [1 0 0 0 1], 1,1, []);
        startEvent = cellfun(@(x)strcmp(x,'Starting Recording'),EventStrings);
        startTime = timeStamps(startEvent);
        
        endEvent = cellfun(@(x)strcmp(x,'Stopping Recording'),EventStrings);
        endTime = timeStamps(endEvent);
      
    otherwise
        warning('File type %s not currently supported by this function. Returning NaN', ext);
        startTime = NaN; endTime = NaN; createdTime = NaN; closedTime = NaN;
        return
end

startTime = datetime(startTime, 'ConvertFrom', 'posixtime');
endTime = datetime(endTime, 'ConvertFrom', 'posixtime');

timeCreated = regexp(header, '(?<=\-TimeCreated ).*', 'match', 'once');
empties = cellfun(@isempty, timeCreated);
createdTime = datetime(timeCreated{~empties});

timeClosed = regexp(header, '(?<=\-TimeClosed ).*', 'match', 'once');
empties = cellfun(@isempty, timeClosed);
closedTime = datetime(timeClosed{~empties});