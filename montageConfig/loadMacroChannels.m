function Data = loadMacroChannels(macroChannels, miscChannels)

channelData = reshape(flatten(macroChannels), 3, [])';
miscMacroData = reshape(flatten(miscChannels), 3, [])';
Data = sortrows([channelData; miscMacroData], 3);