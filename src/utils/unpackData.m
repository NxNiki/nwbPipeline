function outFileNames = unpackData(inFileNames, outFileNames, outFilePath, verbose, skipExist)
% unpackData(inFileNames, outFilePath, verbose): read neuralynx file and
% save to .mat files.

% inFileName: datatable(m, n). '.ncs' files for one experiment. Should have
% same timestamps.

% timestamps: Unix time samplingInterval: matlab duration object.
% samplingRate can be calculate as: seconds(1)/samplingInterval.

% This function uses library developed by Ueli Rutishauser:
% https://www.urut.ch/new/serendipity/index.php?/pages/nlxtomatlab.html As
% this function calls mex files complied in intel/amd machine, it will not
% work on mac with Matlab >= 2023b which run natively on apple silicon.


if nargin < 4 || isempty(verbose)
    verbose = 1;
end

if nargin < 5
    skipExist = 1;
end

makeOutputPath(inFileNames(:), outFilePath, skipExist)

% TO DO: probably don't want to hard code timestamp file name.
timestampFileName = 'lfpTimeStamps';

% compute stampstamp for the first channel in each segment.
% each segment has a suffix with pattern '001'. We need precompute when to
% cmopute timestamps as deciding within parfor will cause issues.
suffix = regexp(outFileNames(1,:), '(?<=_)\d{3}(?=.mat)', 'match', 'once');

% unpack ncs files:
for segment = 1: size(inFileNames, 2)
    % use non-parallel loop to read timestamps:
    
    timestampFullFile = fullfile(outFilePath, [timestampFileName, '_', suffix{segment}]);
    startIndx = 1;
    if ~(skipExist && exist(timestampFullFile, "file"))
        computedTimeStamps = NaN;
        while isnan(computedTimeStamps) 
            [signal, ADBitVolts, timestamps, numSamples, samplingInterval, ~] = Nlx_readCSC(inFileNames{startIndx, segment}, outFilePath);
            computedTimeStamps = computeTimeStamps(timeStamps, numSamples);

            if ~isnan(computedTimeStamps)
                saveTimestamps(timestamps, samplingInterval, timestampFullFile)
            end
        end
    end
    


    parfor i = startIndx:length(inFileNames)
        [~, ~, ext] = fileparts(inFileNames{i, segment});

        if ~strcmp(ext, '.ncs')
            warning('input file is not ncs!')
            continue
        end
    
        [~, outFileName, ~] = fileparts(outFileNames{i, segment});
        outFileNameTemp = fullfile(outFilePath, [outFileName, 'temp.mat']);
        outFileName = fullfile(outFilePath, [outFileName, '.mat']);
    
        if skipExist && ~computeTS && exist(outFileName, "file") && checkMatFileCorruption(outFileName) 
            continue
        end
    
        if exist(outFileNameTemp, "file")
            warning('delete temp file: %s\n', outFileNameTemp);
            delete(outFileNameTemp);
        end
    
        if verbose
            fprintf('unpack: %s\nto: %s\n', inFileNames{i, segment}, outFileName);
        end

    
        [signal, ADBitVolts, ~, ~, samplingInterval, ~] = Nlx_readCSC(inFileNames{i, segment}, outFilePath);
        
        num_samples = length(signal);
        timeend = (num_samples-1) * samplingInterval;
    
        matobj = matfile(outFileNameTemp, 'Writable', true);
        matobj.samplingInterval = samplingInterval;
        matobj.samplingIntervalSeconds = seconds(samplingInterval);
        matobj.data = signal;
        matobj.time0 = 0;
        matobj.timeend = timeend;
        matobj.timeendSeconds = seconds(timeend);
        matobj.ADBitVolts = ADBitVolts;
    

    
        movefile(outFileNameTemp, outFileName);
        outFileNames{i, segment} = outFileName;
    end
end
