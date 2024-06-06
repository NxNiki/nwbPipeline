function [macroChannels, microChannels] = createChannels(montageConfigFile)
% read montage json file and save macro and micro channel names as cell 
% arrays. For macro Channels, unused channels will be filled with empty
% value so that we can match to the .ncs files (unused channels will also
% save files).

montageConfig = readJson(montageConfigFile);
macroChannels = {};
[~, Data] = loadMacroChannels(montageConfig.macroChannels, montageConfig.miscChannels);
for i = 1: size(Data, 1)
    numChannels = Data{i, 3} - Data{i, 2} + 1;
    startIdx = Data{i, 2};
    for j = 1: numChannels
        macroChannels(startIdx+j-1) = {[Data{i, 1}, num2str(j)]};
    end
end
macroChannels = macroChannels(:);

microChannels = {};
microConfig = montageConfig.Headstages;
headStages = fieldnames(microConfig);
for i = 1: length(headStages)
    ports = fieldnames(microConfig.(headStages{i}));
    for j = 1: length(ports)
        channel = microConfig.(headStages{i}).(ports{j});
        numChannel = channel.Micros;
        brainLabel = channel.BrainLabel;
        channels = arrayfun(@(idx) [headStages{i}, num2str(j), '-', brainLabel, num2str(idx)], 1: numChannel, 'UniformOutput', false);
        microChannels = [microChannels; channels(:)];
    end
end

