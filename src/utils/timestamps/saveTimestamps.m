function saveTimestamps(timestamps, samplingInterval, timestampFile, rawNcsFile)
% timestamps should be in unix time
% samplingInterval: float in seconds

    if nargin < 4
        rawNcsFile = '';
    end

    num_samples = length(timestamps);
    timeend = (num_samples-1) * samplingInterval;

    [fpath, fname, ext] = fileparts(timestampFile);
    if ~strcmp(ext, '.mat')
        timestampFile = fullfile(fpath, [fname, '.mat']);
    end

    timestampFileTemp = strrep(timestampFile, '.mat', '_temp.mat');
    if exist(timestampFileTemp, "file")
        delete(timestampFileTemp)
    end

    try
        matobj = matfile(timestampFileTemp, Writable=true);
        matobj.timeStamps = timestamps;
        matobj.samplingInterval = samplingInterval;
        matobj.samplingIntervalSeconds = seconds(samplingInterval);
        matobj.time0 = 0;
        matobj.timeend = timeend;
        matobj.timeendSeconds = seconds(timeend);
        matobj.rawNcsFile = rawNcsFile;

        movefile(timestampFileTemp, timestampFile);

        % save a figure of the diff of timestamps:
        if any(diff(timestamps) < 0)
            warning('non monotonic timestamps found in: %s\n', timestampFile);
        end
        
        fig = figure('Visible', 'off');
        plot(diff(timestamps));
        xlabel(strrep(timestampFile, '.mat', ''));       
        ylabel('diff of timestamps');    
        saveas(fig, strrep(timestampFile, '.mat', '.png'));
        close(fig);

    catch err
        fprintf('error happened saving timestamp file: %s\n', timestampFile);
        disp(err);
        disp(err.stack);
    end

    

end
