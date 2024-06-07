function logMessage(logFilePath, logMessage)
    % Open the log file for writing in append mode
    logFile = fopen(logFilePath, 'a');
    
    if logFile == -1
        error('Failed to open log file');
    end
    
    % Get the current date and time
    currentTime = datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss');
    
    % Create the log message with timestamp
    formattedMessage = sprintf('[%s] %s\n', char(currentTime), logMessage);
    
    % Write the log message to the file
    fprintf(logFile, formattedMessage);
    
    % Close the log file
    fclose(logFile);
end