function[stimTag, stimId, stimName] = getStimInfo(stimPath, ext)
% read stimuli name and id from path.

if ~exist('ext', 'var') || isempty(ext)
    ext = '.*';
end

if startsWith(ext, '*')
    ext = ext(2:end);
end
if ~startsWith(ext, '.')
    ext = ['.', ext];
end

stimDir = dir(fullfile(stimPath, ['*', ext]));
stimDir = stimDir(arrayfun(@(x) x.name(1) ~= '.', stimDir));
stimDir = stimDir(~[stimDir.isdir]);

if isempty(stimDir)
    warning('no stimuli found with extention: %s', ext);
end

stimName = {stimDir.name};
stimName = stimName(:);
stimTag = regexp({stimDir.name}, '.*?(?=_id)', 'match', 'once');
stimTag = stimTag(:);
stimId = regexp({stimDir.name}, '(?<=_id)\d+', 'match', 'once');
stimId = stimId(:);
stimId = cellfun(@str2num, stimId);

