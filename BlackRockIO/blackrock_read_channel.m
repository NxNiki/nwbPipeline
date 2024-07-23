function blackrock_read_channel(inFile, expFilePath, timestampsFile, electrodeInfoFile, skipExist)

[~, ~, samplingInterval] = readTimestamps(timestampsFile);

electrodeInfoObj = matfile(electrodeInfoFile);
enum = electrodeInfoObj.enum;
num_chunks = electrodeInfoObj.num_chunks;
chunkSize = electrodeInfoObj.chunkSize;
nchan = electrodeInfoObj.nchan;
num_samples = electrodeInfoObj.num_samples;

partiallyFinished = dir([expFilePath, base_outfile, '_*_*.mat']);
if isempty(partiallyFinished)
    startAt = 1;
    skipSplitting = 0;
else
    chunksCompleted = unique(arrayfun(@(x)str2double(regexp(x.name, '(?<=_)\d*(?=.mat)','match','once')), partiallyFinished));
    if exist([expFilePath, base_outfile, '_', num2str(enum(end)), '_', num2str(num_chunks), '.mat'], 'file') % ismember(enum(end),chunksCompleted)
        % we've finished splitting already
        skipSplitting = 1;
    else
        skipSplitting = 0;

        if (length(partiallyFinished)/length(chunksCompleted))==...
                fix((length(partiallyFinished)/length(chunksCompleted)))
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
        status = fseek(fid,(startAt-1)*nchan*chunkSize*2,'cof');
        if (status == -1)
            error('Cannot fseek to requested location in file %s.\n', inFile);
        end
    end
end

if ~skipSplitting
    for i=startAt:num_chunks
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
                saveChannel_split(chunk_data,ch,base_outfile,enum,expFilePath,i);
            end

            fprintf('Done.\n');
        else
            for ch=1:nchan
                saveChannel_notSplit(chunk_data,samplingInterval,ch,base_outfile,enum,expFilePath);
            end

            fprintf('Done.\n');
        end
    end

    fclose(fid);

    clear chunk_data;
    data = zeros(1, num_samples ,'int16');
end
if num_chunks==1
    return
end
%% Merge channel-by-channel data into single files
% if we skipped splitting, we need to check whether we had started merging
% already...
if skipSplitting
    mergedAlready = dir([expFilePath,base_outfile,'*.mat']);
    mergedAlready = mergedAlready(arrayfun(@(x)~strcmp(x.name(1:length(base_outfile)+1),[base_outfile,'_']),mergedAlready));
    mergedAlready = arrayfun(@(x)str2double(regexp(x.name,['(?<=',base_outfile,')\d*'],'match','once')),...
        mergedAlready);
    mergedAlready(mergedAlready>=129) = [];
    if isempty(mergedAlready)
        startAt = 1;
    else
        startAt = max(mergedAlready)+1;
    end
else
    startAt = 1;
end

% paste together all chunks of each channel:
parfor ch=startAt:nchan
    mergeLoop1(ch,nchan,num_chunks,chunkSize,base_outfile,enum,expFilePath,samplingInterval)
end

% delete the piece-by-piece files
parfor ch=1:nchan
    fprintf('Deleting chunks for channel %d (of %d)...', ch, nchan);
    for i=1:num_chunks
        cur_chunk_file = sprintf('%s_%d_%d.mat', base_outfile, enum(ch), i);
        if exist([expFilePath cur_chunk_file],'file')
            delete([expFilePath cur_chunk_file]);
        end
    end
    fprintf('Done.\n');
end
end

function saveChannel_split(chunk_data,ch,base_outfile,enum,saveDir,i)
data1 = chunk_data(ch, :);
outfile = sprintf('%s_%d_%d.mat', base_outfile, enum(ch), i);
waitForSaveDir(saveDir);
save([saveDir,outfile], 'data1');
fprintf('.')
end

function saveChannel_notSplit(chunk_data,samplingInterval,ch,base_outfile,enum,saveDir)
data = chunk_data(ch, :);
outfile = sprintf('%s%d.mat', base_outfile, enum(ch));
waitForSaveDir(saveDir);
save([saveDir,outfile], 'data','samplingInterval','-v7.3');
fprintf('.')
end

function mergeLoop1(ch,nchan,num_chunks,chunk_size,base_outfile,enum,saveDir,samplingInterval)
fprintf('Merging chunks for channel %d (of %d)...', ch, nchan);

last_chunk_start_ind = 1;
data = nan(1, num_chunks * chunk_size);

for i=1:num_chunks
    cur_chunk_file = sprintf('%s_%d_%d.mat', base_outfile, enum(ch), i);
    d = load([saveDir, cur_chunk_file]);
    cur_chunk_sz = length(d.data1);
    data(1, last_chunk_start_ind:(last_chunk_start_ind + cur_chunk_sz-1)) = d.data1;
    last_chunk_start_ind = last_chunk_start_ind + cur_chunk_sz;
end

data(last_chunk_start_ind:end) = [];
outfile = sprintf('%s%d.mat', base_outfile, enum(ch));
waitForSaveDir(saveDir);
save([saveDir,outfile], 'data', 'samplingInterval','-v7.3');

if ch==1 && ~exist(fullfile(saveDir,'lfpTimestamps.mat'),'file')
    timeStamps = colonByLength(0,samplingInterval,length(data));
    time0 = 0;
    timeend = timeStamps(end);
    save(fullfile(saveDir,'lfpTimeStamps.mat'),...
        'timeStamps','time0','timeend');
end

fprintf('Done.\n');

end