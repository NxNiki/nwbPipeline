function macroData = loadMacroChannels(channels)

if ~isempty(channels)
    ncols = length(channels{1});
    macroData = reshape(flatten(channels), ncols, [])';
    macroData = sortrows(macroData, ncols);
else
    macroData = [];
end
