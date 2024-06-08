function [Data, macroData, miscData] = loadMacroChannels(macroChannels, miscChannels)

if ~isempty(macroChannels)
    macroData = reshape(flatten(macroChannels), 3, [])';
    macroData = sortrows(macroData, 3);
else
    macroData = [];
end

if ~isempty(miscChannels)
    miscData = reshape(flatten(miscChannels), 3, [])';
    miscData = sortrows(miscData, 3);
else
    miscData = [];
end

Data = [macroData; miscData];
if ~isempty(Data)
    Data = sortrows(Data, 3);
else
    Data = cell(1, 3);
end