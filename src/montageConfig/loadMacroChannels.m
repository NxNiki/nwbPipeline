function macroData = loadMacroChannels(channels)

ncols = length(channels{1});
if ~isempty(channels)
    macroData = reshape(flatten(channels), ncols, [])';
    macroData = sortrows(macroData, ncols);
else
    macroData = [];
end
