function [tsFileName, electrodeInfoFileName] = blackrock_read_header(inFile, expFilePath, chunkSize, skipExist)
% read header from black rock file and save timestamps and electrode
% information.


    if nargin < 3 || isempty(chunkSize)
        chunkSize = 2e6;
    end

    if nargin < 4 || isempty(skipExist)
        skipExist = 1;
    end
    
    [samplingInterval, outputFilePath, electrodeInfoFileName] = parseInputFile(inFile, expFilePath);
    tsFileName = fullfile(outputFilePath, 'lfpTimeStamps_001.mat');
    electrodeInfoFileName = fullfile(outputFilePath, electrodeInfoFileName);
    
    if skipExist && exist(tsFileName, "file") && exist(electrodeInfoFileName, "file")
        return
    end

    bytes_per_samp = 2;
    fid = fopen(inFile, 'r', 'ieee-le');
    if fid == -1
        error('Could not open samples file.');
    end
    
    %% Read Header
    file_type_ID = fread(fid, 8, 'char=>char')';
    switch file_type_ID
        case 'NEURALSG'
            fseek(fid, 16, 'cof');
            q = fread(fid, 8, 'char');
            period = q(1);
            nchan =  q(5);
            enum = fread(fid, nchan, 'int32');  %% electrode numbers
    
            % Compute the number of samples in the whole file (per channel), to
            % optimize the reading:
            start_pos = ftell(fid);
            status = fseek(fid, 0, 'eof');
            if (status == -1)
                error('Cannot fseek file %s.\n', inFile);
            end
            end_pos = ftell(fid);
            num_samples = (end_pos - start_pos) ./ bytes_per_samp ./ nchan;  % #samples per channel.
            if (num_samples ~= fix(num_samples))
                % num_samples is not natural - probably wrong calculation or file truncation:
                error(['#samples per channel is not natural (num_samples=%g; start_pos=%d;', ...
                    'end_pos=%d).\n'], num_samples, start_pos, end_pos);
            end
            % move file-read position to beginning of data.
            % (from beginning of file (bof), go forward 8+16+8+nchan*4 bytes
            % because the first 8 are file_typeID, then skip 16 (don't know why, but
            % they do above), then the next 8 are 'q' above (including period and
            % channel).
            % The next nchan*4 are electrode numbers (the *4 is because electrode
            % numbers are 'int32', which are 4 bytes each.
            status = fseek(fid, 24 + 8 + nchan * 4, 'bof');
            if (status == -1)
                error('Cannot fseek file %s.\n', inFile);
            end
        case 'NEURALCD'
            % to understand this block of code, see documentation of header here:
            % http://support.blackrockmicro.com/KB/View/166838-file-specifications-packet-details-headers-etc
            fseek(fid, 2, 'cof'); % skip file type id
            bytesInHeader = fread(fid, 1, 'uint32');
            fseek(fid, 16+256, 'cof'); % skip label; comment
            period = fread(fid, 1, 'uint32');
            fseek(fid, 4+16, 'cof'); % skip time resolution and time origin
            nchan = fread(fid, 1, 'uint32');
            enum = zeros(1, nchan);
            for k = 1:nchan
                fseek(fid, 2, 'cof'); % skip type
                enum(k) = fread(fid, 1, 'uint16');
                fseek(fid, 16+1+1+2+2+2+2+16+4+4+2+4+4+2, 'cof'); % skip remainder of channel info
            end
            assert(bytesInHeader == ftell(fid),...
                'Something went wrong with reading the header!');
    
            start_pos = bytesInHeader+1+4+4;
            status = fseek(fid, 0, 'eof');
            if (status == -1)
                error('Cannot fseek file %s.\n', inFile);
            end
            end_pos = ftell(fid);
            num_samples = (end_pos - start_pos) ./ bytes_per_samp ./ nchan;  % #samples per channel.
            if (num_samples ~= fix(num_samples))
                % num_samples is not natural - probably wrong calculation or file truncation:
                error(['#samples per channel is not natural (num_samples=%g; start_pos=%d;', 'end_pos=%d).\n'], num_samples, start_pos, end_pos);
            end
    
            status = fseek(fid, start_pos, 'bof');
            if (status == -1)
                error('Cannot fseek file %s.\n', inFile);
            end
        otherwise
            error('Unknown file type %s (currently supports only NEURALSG and NEURALCD).', file_type_ID);
    end
    

    % save timestamps:
    timeStamps = colonByLength(0, seconds(samplingInterval), num_samples);
    time0 = 0; 
    timeend = timeStamps(end);

    if ~exist(outputFilePath, "dir")
        mkdir(outputFilePath)
    end
    
    save(tsFileName, 'timeStamps', 'time0', 'timeend', 'samplingInterval', '-v7.3');
    
    % save electrode_info:
    num_chunks = ceil(num_samples ./ chunkSize);
    % save general info about the electrodes and recording times:
    save(electrodeInfoFileName, 'enum', 'nchan', 'period', 'inFile', ...
         'bytes_per_samp', 'num_samples', 'chunkSize', 'num_chunks');

    fclose(fid);
end
