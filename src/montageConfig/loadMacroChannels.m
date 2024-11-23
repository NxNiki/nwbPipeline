function macroData = loadMacroChannels(channels)

if isempty(channels)
    macroData = [];
    return
end

ncols = length(channels{1});

if ~isempty(channels)
    macroData = reshape(flatten(channels), ncols, [])';
    macroData = sortrows(macroData, ncols);
else
    macroData = cell(1, ncols);
    macroData{1, 1} = '';
end
