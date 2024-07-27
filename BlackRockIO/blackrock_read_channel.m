function outFiles = blackrock_read_channel(inFile, expFilePath, electrodeInfoFile, skipExist)
% Function to read Blackrock channel data using code adapted from neuroport2mat_all2.m (PDM).
% Blackrock data is saved in a single file containing all channels, and
% individual channels cannot be read separately. This function splits the
% data into multiple chunks and then merges these chunks for each channel.


if nargin < 4 || isempty(skipExist)
    skipExist = 0;
end

electrodeInfoObj = matfile(electrodeInfoFile);
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
end

if ~skipSplitting
    for i=startAt: num_chunks
        % DO NOT run this in parallel; the whole point of chunking is to
        % keep it below memory demands...
        fprintf('Reading chunk #%d (of %d)...\n', i, num_chunks);

        [chunk_data, count] = fread(fid, [nchan, chunkSize], 'int16=>int16');
        if (count/nchan < chunkSize) && (i ~= num_chunks)
            % only the last chunk may be shorter than chunk_size:
            error('Chunk #%d short read (%d elems instead of %d)', i, count, chunkSize);
        end

        fprintf('Done.  Splitting...\n');
        for ch=1:nchan
            if num_chunks>1
                saveChannel_split(chunk_data, ch, tempOutfile, enum, i);
            else
                saveChannel_notSplit(chunk_data, samplingInterval, ch, tempOutfile, enum);
            end
        end
        fprintf('Done.\n');
    end

    fclose(fid);

    clear chunk_data;
end

if num_chunks==1
    return
end

%% Merge channel-by-channel data into single files
% paste together all chunks of each channel:
parfor ch = 1:nchan
    outfile = sprintf('%s%d.mat', tempOutfile, enum(ch));
    if exist(outfile, "file")
        outFiles{ch} = outfile;
    else
        outFiles{ch} = mergeLoop1(ch, nchan, num_chunks, chunkSize, tempOutfile, enum(ch), samplingInterval);
    end
end

% delete the piece-by-piece files
parfor ch=1:nchan
    fprintf('Deleting chunks for channel %d (of %d)...\n', ch, nchan);
    for i=1:num_chunks
        cur_chunk_file = sprintf('%s%d_%d.mat', tempOutfile, enum(ch), i);
        if exist(cur_chunk_file,'file')
            delete(cur_chunk_file);
        end
    end
    fprintf('Done.\n');
end
end

function saveChannel_split(chunk_data, ch, base_outfile, enum, i)
data1 = chunk_data(ch, :);
outfile = sprintf('%s%d_%d.mat', base_outfile, enum(ch), i);
save(outfile, 'data1');
end

function saveChannel_notSplit(chunk_data, samplingInterval, ch, base_outfile, enum)
data = chunk_data(ch, :);
outfile = sprintf('%s%d.mat', base_outfile, enum(ch));
save(outfile, 'data', 'samplingInterval', '-v7.3');
end

function outfile = mergeLoop1(ch, nchan, num_chunks, chunk_size, base_outfile, enum_ch, samplingInterval)
fprintf('Merging chunks for channel %d (of %d)...', ch, nchan);

last_chunk_start_ind = 1;
data = nan(1, num_chunks * chunk_size);

for i=1:num_chunks
    cur_chunk_file = sprintf('%s%d_%d.mat', base_outfile, enum_ch, i);
    d = load(cur_chunk_file);
    cur_chunk_sz = length(d.data1);
    data(1, last_chunk_start_ind:(last_chunk_start_ind + cur_chunk_sz-1)) = d.data1;
    last_chunk_start_ind = last_chunk_start_ind + cur_chunk_sz;
end

data(last_chunk_start_ind:end) = [];
outfile = sprintf('%s%d.mat', base_outfile, enum_ch);
save(outfile, 'data', 'samplingInterval', '-v7.3');

fprintf('Done.\n');

end