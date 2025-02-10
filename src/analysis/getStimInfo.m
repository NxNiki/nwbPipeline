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
    [stimTag, stimId, stimName] = deal([]);
    return
end

stimName = {stimDir.name};

if isempty(stimName)
    [stimTag, stimId, stimName] = deal([]);
    return
end

stimName = stimName(:);
stimTag = regexp({stimDir.name}, '.*?(?=_id)', 'match', 'once');
stimTag = stimTag(:);
stimId = regexp({stimDir.name}, '(?<=_id)\d+', 'match', 'once');
stimId = stimId(:);

if any(isempty(stimTag))
    warning('empty tags in stimuli folder!')
    empty_idx = isempty(stimTag);
    stimName(empty_idx) = [];
    stimId(empty_idx) = [];
    stimTag(empty_idx) = [];
end

stimId = cellfun(@str2num, stimId);

