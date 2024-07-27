function channel_labels = read_ns5_channel_labels(filename)
    % WIP...

    % Open the file for reading
    fid = fopen(filename, 'r');
    if fid == -1
        error('Could not open file.');
    end
    
    % Read the basic header
    file_type = fread(fid, [1, 8], '*char');
    if ~strcmp(file_type, 'NEURALCD')
        error('File is not a valid .ns5 file.');
    end
    
    % Skip the rest of the basic header to get to the extended headers
    fseek(fid, 8, 'cof'); % Skip bytes 9-16
    bytes_in_headers = fread(fid, 1, 'uint32'); % Bytes in headers (17-20)
    fseek(fid, 286, 'cof'); % Skip bytes 21-306
    
    % Calculate the number of channels from the extended header length
    num_channels = round((bytes_in_headers - 8 - 306) / 66)

    % Read the extended header for each channel
    channel_labels = cell(num_channels, 1);
    for i = 1:100
        i
        elec_id = fread(fid, 1, 'uint16'); % Electrode ID (bytes 1-2)
        fseek(fid, 2, 'cof'); % Skip connector bank and pin (bytes 3-4)
        label = fread(fid, [1, 16], '*char'); % Label (bytes 5-20)
        channel_labels{i} = strtrim(label); % Remove trailing spaces
        fseek(fid, 46, 'cof'); % Skip the rest of the extended header (bytes 21-66)
    end
    
    % Close the file
    fclose(fid);
end
