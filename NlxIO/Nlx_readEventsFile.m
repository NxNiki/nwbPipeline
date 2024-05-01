function [TimeStamps,TTLs,EventStrings,Header] = Nlx_readEventsFile(Filename,displayHeader)
% [TimeStamps, EventIDs, TTLs, Extras, EventStrings, Header] =...
%     Nlx2MatEV( Filename, FieldSelection, ExtractHeader,ExtractMode, ModeArray );

[TimeStamps, TTLs, EventStrings, Header] =...
    Nlx2MatEV_v3( Filename, [1 0 1 0 1], 1,1,[]);
TimeStamps = TimeStamps*1e-6;% convert to seconds
if ~exist('displayHeader','var') || isempty(displayHeader) || displayHeader
disp(Header)
end