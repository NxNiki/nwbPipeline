function logMessage(logFile, logMessage)
    % Maximum time to wait for the log file to become available (in seconds)
    maxWaitTime = 10; 
    startTime = tic; % Start the timer
    
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
    logFile = fopen(logFile, 'a');
    
    if logFile == -1
        warning('Failed to open log file: %s\n', logFile);
    end
    
    % Get the current date and time
    currentTime = datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss.SSS');
    
    % Create the log message with timestamp
    formattedMessage = sprintf('[%s] %s\n', char(currentTime), logMessage);
    
    % Write the log message to the file
    fprintf(logFile, formattedMessage);
    
    % Close the log file
    fclose(logFile);
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
