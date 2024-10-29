function logMessage(logFile, logMessage, verbose)
    if nargin < 3
        verbose = false;
    end
    % Maximum time to wait for the log file to become available (in seconds)
    maxWaitTime = 10;
    startTime = tic; % Start the timer

    % Check if the log file's directory exists, if not, create it
    logDir = fileparts(logFile);
    if ~exist(logDir, 'dir')
        mkdir(logDir); % Create the directory if it does not exist
    end

    % Check if the log file exists; if not, create it
    if ~exist(logFile, "file")
        % Create and open the log file
        fid = fopen(logFile, 'w'); % Use 'w' to create the file
        if fid == -1
            warning('Failed to create log file: %s\n', logFile);
            return;
        end
        fclose(fid); % Close the file after creation
    end

    % Wait until the file becomes available
    while true
        % Attempt to open the log file with exclusive access to check if it's free
        isFileAvailable = checkFileAvailability(logFile);

        if isFileAvailable
            break; % Exit the loop if the file is available
        end

        % Check if the maximum wait time has been exceeded
        elapsedTime = toc(startTime);
        if elapsedTime > maxWaitTime
            fprintf('Skipped writing log due to timeout: %s\n', logMessage);
            return; % Skip writing the log
        end

        % Pause for a short time before checking again
        pause(0.1); % Adjust the pause time as needed
    end

    % Open the log file for writing in append mode
    fid = fopen(logFile, 'a');

    if fid == -1
        warning('Failed to open log file: %s\n', logFile);
        return;
    end

    % Get the current date and time
    currentTime = datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss.SSS');

    % Create the log message with timestamp
    formattedMessage = sprintf('[%s] %s\n', char(currentTime), logMessage);

    if verbose
        disp(formattedMessage);
    end

    % Write the log message to the file
    fprintf(fid, formattedMessage);

    % Close the log file
    fclose(fid);
end

function fileIsAvailable = checkFileAvailability(logFile)
    fileIsAvailable = false;
    try
        % Attempt to open the file with 'r+' (read/write) permission
        fid = fopen(logFile, 'r+');
        if fid ~= -1
            % If the file is opened successfully, close it immediately
            fclose(fid);
            fileIsAvailable = true;
        end
    catch
        % If fopen fails, it usually means the file is locked by another process
        fileIsAvailable = false;
    end
end
