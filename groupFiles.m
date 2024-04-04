function [groups, fileNames, groupFileNames, eventFileNames] = groupFiles(directories, groupRegPattern, suffixRegPattern, orderByCreateTime, ignoreFilesWithSizeBelow)
% groupFiles: group files based on their name pattern.
% Details:
%    This function lists files in the directory that matches specific
%    patterns and organize them into a cell array. Files in the same group
%    are listed in the same row. e.g.
%       {'dir/GA1-RA1.ncs', 'dir/GA1-RA1_0002.ncs', 'dir/GA1-RA1_0003.ncs';
%        'dir/GA1-RA2.ncs', 'dir/GA1-RA2_0002.ncs', 'dir/GA1-RA2_0003.ncs'}
%
%
% Inputs:
%    directories - string, cell [1 n]. A list of directories in which the
%    files will be grouped based on their name pattern. Files in different
%    directories will be concatenated by column.
%
%    groupRegPattern - string. A regular expression used to determine the
%    group name of files in the directory. File names is decomposed to
%    `[group]_[suffix].[extension]`. Files with same group will be put in
%    the same row in the returned cell array.
%
%    suffixRegPattern - string. A regular expression used to determine the
%    suffix of files in the directory. File names is decomposed to
%    `[group]_[suffix].[extension]`.
%
%    orderByCreateTime - boolean. If true, order files in the same group
%    (row) by create data, otherwise, order by suffix. Empty suffix will be
%    first. This only works within direcotory.
%
%    ignoreFilesWithSizeBelow - int. File size in bytes. Files with smaller
%    size then this will be ignored.
%
% Outputs:
%    groups - cell [m]. group pattern extracted from file names.
%
%    fileNames - cell [m, n]. file names grouped in rows.
%
%    groupFileNames - dataTable [m, n + 1]. data table combines groups and
%    fileNames, this can be saved as .csv file to check the files combined.
%
%    eventFileNames - cell [n]. '.env' files to be combined. If no event
%    files found in directories{i}, it will be empty.

% Example:
%{

%}
% See also: Nlx2MatCSC_v3, Mat2NlxCSC, combineNcsFiles

% Author:                          Xin Niu
% Email:                           xinniu@mednet.ucla.edu
% Version history revision notes:
%   created by Xin based on work by Chris Dao. Feb-22-2024.


% set true for testing:
REVERSE_TEMPORAL_ORDER = true;


if nargin < 2 || isempty(groupRegPattern)
    groupRegPattern = '.*?(?=\_\d{1}|\.ncs)';
end

if nargin < 3 || isempty(suffixRegPattern)
    suffixRegPattern = '(?<=\_)\d*';
end

if nargin < 4 || isempty(orderByCreateTime)
    orderByCreateTime = true;
end

if nargin < 5 || isempty(ignoreFilesWithSizeBelow)
    ignoreFilesWithSizeBelow = 16384;
end

if ischar(directories)
    directories = {directories};
end

groupFileNamesList = cell(1, length(directories));
eventFileNames = cell(1, length(directories));

for i = 1:length(directories)

    % .ncs files:
    filenames = getNeuralynxFiles(directories{i}, '.ncs', ignoreFilesWithSizeBelow);
    fileGroup = unique(cellfun(@(x)regexp(x, groupRegPattern, 'once', 'match'), filenames, 'UniformOutput', false));
    fileSuffix = unique(cellfun(@(x)regexp(x, suffixRegPattern, 'once', 'match'), filenames, 'UniformOutput', false));

    idx = ~cellfun('isempty', fileSuffix);
    fileSuffix(idx) = sort(cellfun(@(x) ['_', x], fileSuffix(idx), 'UniformOutput', false));

    [rowMat, colMat] = meshgrid(fileSuffix, fileGroup);
    iGroupFileNames = arrayfun(@(x, y) fullfile(directories{i}, [y{:}, x{:}, '.ncs']), rowMat, colMat, 'UniformOutput', false);

    % remove file if it does not exists:
    iGroupFileNames = removeNonExistFile(iGroupFileNames, true);

    if orderByCreateTime && length(fileSuffix)>1
        order = zeros(size(iGroupFileNames));
        for j = 1: size(order, 1)
            fprintf("groupFiles: order files by create time for group: %s.\n", fileGroup{j});
            order(j,:) = orderFilesByTime(iGroupFileNames(j,:), REVERSE_TEMPORAL_ORDER);
        end
        iGroupFileNames = iGroupFileNames(order);
    elseif length(fileSuffix)>1
        warning("groupFiles: order files by file name. Make sure the order is correct by checking header of raw data!")
    end

    iGroupFileNames = cell2table([fileGroup(:), iGroupFileNames]);
    iGroupFileNames.Properties.VariableNames{1} = 'fileGroup';
    groupFileNamesList(i) = {iGroupFileNames};

    % nev files:
    filenames = getFileNames(directories{i}, '*.nev', ignoreFilesWithSizeBelow);
    filenames = cellfun(@(x) fullfile(directories{i}, x), filenames, 'UniformOutput', false);
    if length(filenames) > 1
        % order .nev files by start time stamp:
        order = orderFilesByTime(filenames);
        filenames = filenames(order);
    end
    eventFileNames{i} = filenames;

end

eventFileNames = flatten(eventFileNames);

groupFileNames = groupFileNamesList{1};
for i = 2:length(groupFileNamesList)
    groupFileNames = outerjoin(groupFileNames, groupFileNamesList{i}, 'Keys', 'fileGroup', 'MergeKeys', true);
end

groups = table2cell(groupFileNames(:, 1));
fileNames = table2cell(groupFileNames(:, 2:end));

end

function files = removeNonExistFile(files, parallel)
fprintf('groupFiles: remove non-existing files...\n');
[r, c] = size(files);
files = files(:);

if parallel
    existIdx = zeros(length(files), 1);
    parfor i = 1: length(files)
        existIdx(i) = exist(files{i}, 'file');
    end
else
    existIdx = cellfun(@(f)exist(f, 'file'), files);
end

if any(~existIdx)
    for i = find(~existIdx)
        warning('groupFiles: file missing: %s.', files{i});
    end
end

files(~existIdx) = {''};
files = reshape(files, r, c);
end

function order = orderFilesByTime(files, reverse)
if nargin < 2
    reverse = false;
end
createTimes = NaT(length(files), 1);
parfor i = 1:length(files)
    [~, ~, createTime, ~] = Nlx_getStartAndEndTimes(files{i});
    createTimes(i) = createTime;
end
[~, order] = sort(createTimes);

if reverse
    warning('groupFiles: reverse temporal order of files. This is only used for testing!')
    order = order(length(files):-1:1);
end
end


function res = flatten(cellArray)
if ~iscell(cellArray)
    res = {cellArray};
    return
else
    res = [];
    for i = 1:length(cellArray)
        res = [res, flatten(cellArray{i})];
    end
end
end

