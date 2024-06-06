function [Data, macroData, miscData] = loadMacroChannels(macroChannels, miscChannels)

macroData = reshape(flatten(macroChannels), 3, [])';
macroData = sortrows(macroData, 3);
miscData = reshape(flatten(miscChannels), 3, [])';
miscData = sortrows(miscData, 3);
Data = sortrows([macroData; miscData], 3);