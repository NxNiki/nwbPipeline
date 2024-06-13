function processTTLs()

eventsFile = dir(fullfile(rawPath,'Events*.nev'));
if length(eventsFile)>1
    eventsFile = uigetfile(fullfile(rawPath,'Events*.nev'),'Please locate the correct events file');
    eventsFile = dir(fullfile(rawPath,eventsFile));
end
if length(eventsFile)==1
    eventsFile = fullfile(rawPath,eventsFile.name);
else
    eventsFile = dir(fullfile(cleanPathForThisSystem(thisExp.linkToRaw),'Events*.nev'));
    if ~isempty(eventsFile)
        eventsFile = fullfile(cleanPathForThisSystem(thisExp.linkToRaw), eventsFile.name);
    end
end
if isempty(eventsFile) || ~exist(eventsFile,'file')
    events = load(fullfile(rawPath,'Events.mat'));
    if isfield(events,'events')
        events = events.events;
    end
else
    [events.timeStamps, events.TTLs, events.header] = ...
        Nlx2MatEV_v3(eventsFile, [1 0 1 0 0], 1,1,[]);
    dt = diff(events.timeStamps);
    inds = find(dt<50 & dt>0);
    events.TTLs(inds) = [];events.timeStamps(inds) = [];
    events.timeStamps = events.timeStamps*1e-6;
    save(fullfile(rawPath,'Events.mat'),'events');
end

end