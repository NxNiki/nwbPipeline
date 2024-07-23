<<<<<<< HEAD
function outFiles = blackrock_read_channel(inFile, electrodeInfoFile, skipExist, channelNames)
% Function to read Blackrock channel data.
% Blackrock data is saved in a single file containing all channels. We use
% openNSx.m to read each channel for the .ns3/.ns5/.ns6 file and save data
% separately.
% when using channelNames to rename the file, make sure its order is
% matches data in .NSx file correctly. If some channels are skipped, fill
% the channelNames with empty strings. The best practice would be to have
% the channels named correctly in the .NSx header.

=======
function outFiles = blackrock_read_channel(inFile, expFilePath, electrodeInfoFile, skipExist)
% Function to read Blackrock channel data using code adapted from neuroport2mat_all2.m (PDM).
% Blackrock data is saved in a single file containing all channels, and
% individual channels cannot be read separately. This function splits the
% data into multiple chunks and then merges these chunks for each channel.


if nargin < 4 || isempty(skipExist)
    skipExist = 0;
end
>>>>>>> 191feb1 (unpack black rock, add test script)

if nargin < 3 || isempty(skipExist)
    skipExist = 0;
end

if nargin < 4 || isempty(channelNames)
    channelNames = [];
end

outputFilePath = fileparts(electrodeInfoFile);
electrodeInfoObj = matfile(electrodeInfoFile);
<<<<<<< HEAD
NSx = electrodeInfoObj.NSx;
channelId = NSx.MetaTags.ChannelID;
channelIdx = channelId <= 256;

if ~isempty(channelNames)
    outFiles = channelNames;
else
    % trailing null characters (ASCII code 0) are often used in C-style strings
    % to indicate the end of the string but can be problematic in MATLAB.
    outFiles = cellfun(@(x)fullfile(outputFilePath, [x(double(x) ~= 0), '.mat']), {NSx.ElectrodesInfo(channelIdx).Label}, 'UniformOutput', false);
=======
enum = electrodeInfoObj.enum;
num_chunks = electrodeInfoObj.num_chunks;
chunkSize = electrodeInfoObj.chunkSize;
nchan = electrodeInfoObj.nchan;

[samplingInterval, outputFilePath, ~] = parseInputFile(inFile, expFilePath);
outFiles = cell(1, nchan);
tempOutfile = fullfile(outputFilePath, 'CSC_');
partiallyFinished = dir([tempOutfile, '*_*.mat']);

fid = fopen(inFile, 'r', 'ieee-le');
if fid == -1
    error('Could not open samples file.');
end

if isempty(partiallyFinished) || ~skipExist
    startAt = 1;
    skipSplitting = 0;
else
    chunksCompleted = unique(arrayfun(@(x)str2double(regexp(x.name, '(?<=_)\d*(?=.mat)', 'match', 'once')), partiallyFinished));
    if exist([expFilePath, tempOutfile, num2str(enum(end)), '_', num2str(num_chunks), '.mat'], 'file') % ismember(enum(end),chunksCompleted)
        % we've finished splitting already
        skipSplitting = 1;
    else
        skipSplitting = 0;

        if (length(partiallyFinished)/length(chunksCompleted)) == fix((length(partiallyFinished)/length(chunksCompleted)))
            startAt = length(chunksCompleted)+1;
        else
            startAt = length(chunksCompleted);
        end
        % since we are not starting at the beginning, we need to move the
        % file-read position to the correct place.
        % each chunk read is size [nchan, chunk_size] with 2-bytes per
        % datapoint (since they are int16).
        % thus, if we are to start at the nth block, we should skip
        % (n-1)*nchan*chunk_size*2 bytes from where we would have started.
        % Above, we moved the cursor to the start of the data, so now we
        % need to move the cursor that far from where it already is (cof)...
        status = fseek(fid, (startAt-1)*nchan*chunkSize*2, 'cof');
        if (status == -1)
            error('Cannot fseek to requested location in file %s.\n', inFile);
        end
    end
>>>>>>> 191feb1 (unpack black rock, add test script)
end
nchan = length(outFiles);

<<<<<<< HEAD
parfor i = 1: nchan
    if skipExist && exist(outFiles{i}, 'file')
        continue
    end

    if isempty(outFiles{i})
        continue
=======
if ~skipSplitting
    for i=startAt: num_chunks
        % DO NOT run this in parallel; the whole point of chunking is to
        % keep it below memory demands...
        fprintf('Reading chunk #%d (of %d)...', i, num_chunks);

        [chunk_data, count] = fread(fid, [nchan, chunkSize], 'int16=>int16');
        if (count./nchan < chunkSize)
            % only the last chunk may be shorter than chunk_size:
            if (i ~= num_chunks)
                error('Chunk #%d short read (%d elems instead of %d)', i, count, ...
                    chunkSize);
            end
        end

        fprintf('Done.  Splitting...');
        if num_chunks>1
            for ch=1:nchan
                saveChannel_split(chunk_data, ch, tempOutfile, enum, i);
            end
        else
            for ch=1:nchan
                saveChannel_notSplit(chunk_data, samplingInterval, ch, tempOutfile, enum);
            end
        end
        fprintf('Done.\n');
    end

    fclose(fid);

    clear chunk_data;
    % data = zeros(1, num_samples ,'int16');
end
if num_chunks==1
    return
end
%% Merge channel-by-channel data into single files
% if we skipped splitting, we need to check whether we had started merging
% already...
if skipSplitting
    mergedAlready = dir([expFilePath, tempOutfile, '*.mat']);
    mergedAlready = mergedAlready(arrayfun(@(x)~strcmp(x.name(1:length(tempOutfile)+1), [tempOutfile,'_']), mergedAlready));
    mergedAlready = arrayfun(@(x)str2double(regexp(x.name, ['(?<=',tempOutfile,')\d*'], 'match', 'once')), mergedAlready);
    mergedAlready(mergedAlready>=129) = [];
    if isempty(mergedAlready)
        startAt = 1;
    else
        startAt = max(mergedAlready) + 1;
>>>>>>> 191feb1 (unpack black rock, add test script)
    end

<<<<<<< HEAD
    fprintf('writing data to: %s\n', outFiles{i});
    NSx = openNSx('report','read', inFile, 'channels', i, 'uV', 'precision', 'double');

    data = NSx.Data;
    samplingInterval = seconds(1) / NSx.MetaTags.SamplingFreq;

    tmpOutFile = strrep(outFiles{i}, '.mat', 'tmp.mat');
    if exist(tmpOutFile, 'file')
        delete(tmpOutFile)
    end
    outFileObj = matfile(tmpOutFile);
    outFileObj.data = data;
    outFileObj.samplingInterval = samplingInterval;
    movefile(tmpOutFile, outFiles{i});
end
=======
% paste together all chunks of each channel:
parfor ch=startAt:nchan
    outFiles{ch} = mergeLoop1(ch, nchan, num_chunks, chunkSize, tempOutfile, enum, samplingInterval);
end

% delete the piece-by-piece files
parfor ch=1:nchan
    fprintf('Deleting chunks for channel %d (of %d)...', ch, nchan);
    for i=1:num_chunks
        cur_chunk_file = sprintf('%s%d_%d.mat', tempOutfile, enum(ch), i);
        if exist([expFilePath cur_chunk_file],'file')
            delete([expFilePath cur_chunk_file]);
        end
    end
    fprintf('Done.\n');
end
end

function saveChannel_split(chunk_data, ch, base_outfile, enum, i)
data1 = chunk_data(ch, :);
outfile = sprintf('%s%d_%d.mat', base_outfile, enum(ch), i);
save(outfile, 'data1');
fprintf('.')
end

function saveChannel_notSplit(chunk_data, samplingInterval, ch, base_outfile, enum)
data = chunk_data(ch, :);
outfile = sprintf('%s%d.mat', base_outfile, enum(ch));
waitForSaveDir(saveDir);
save(outfile, 'data', 'samplingInterval', '-v7.3');
fprintf('.')
end

function outfile = mergeLoop1(ch, nchan, num_chunks, chunk_size, base_outfile, enum, samplingInterval)
fprintf('Merging chunks for channel %d (of %d)...', ch, nchan);

last_chunk_start_ind = 1;
data = nan(1, num_chunks * chunk_size);

for i=1:num_chunks
    cur_chunk_file = sprintf('%s%d_%d.mat', base_outfile, enum(ch), i);
    d = load(cur_chunk_file);
    cur_chunk_sz = length(d.data1);
    data(1, last_chunk_start_ind:(last_chunk_start_ind + cur_chunk_sz-1)) = d.data1;
    last_chunk_start_ind = last_chunk_start_ind + cur_chunk_sz;
end

data(last_chunk_start_ind:end) = [];
outfile = sprintf('%s%d.mat', base_outfile, enum(ch));
waitForSaveDir(saveDir);
save(outfile, 'data', 'samplingInterval', '-v7.3');
>>>>>>> 191feb1 (unpack black rock, add test script)

fprintf('Done.\n');

end