function [renameMacroChannels, renameMicroChannels] = createChannels(montageConfigFile)
% read montage json file and save macro and micro channel names as cell 
% arrays.

montageConfig = readJson(montageConfigFile);

renameMacroChannels = {};
renameMicroChannels = {};

microConfig = montageConfig.Headstages;

headStages = fieldnames(microConfig);
for i = 1: length(headStages)
    ports = fieldnames(microConfig.(headStages{i}));
    for j = 1: length(ports)
        channel = microConfig.(headStages{i}).(ports{j});
        numChannel = channel.Micros;
        brainLabel = channel.BrainLabel;
        microChannels = arrayfun(@(idx) [headStages{i}, num2str(j), '-', brainLabel, num2str(idx)], 1: numChannel, 'UniformOutput', false);
        renameMicroChannels = [renameMicroChannels; microChannels(:)];
    end
end