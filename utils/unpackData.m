function unpackData(inFileNames, outFileNames, outFilePath, verbose, skipExist)
% unpackData(inFileNames, outFilePath, verbose): read neuralynx file and
% save to .mat files.

% inFileName: datatable(m, 1). '.ncs' files for one experiment. Should have
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

makeOutputPath(inFileNames, outFilePath, skipExist)

% TO DO: probably don't want to hard code timestamp file name.
timestampFileName = 'lfpTimeStamps';

% compute stampstamp for the first channel in each segment.
% each segment has a suffix with pattern '001'.
suffix = regexp(outFileNames, '(?<=_)\d{3}(?=.mat)', 'match', 'once');
suffix_int = cellfun(@(x) int8(str2double(x)), suffix);
[~, computeTS] = findFirstOccurrence(suffix_int);

% unpack ncs files:
parfor i = 1:length(inFileNames)
    [~, ~, ext] = fileparts(inFileNames{i});
    [~, outFileName, ~] = fileparts(outFileNames{i});
    outFileNameTemp = fullfile(outFilePath, [outFileName, 'temp.mat']);
    outFileName = fullfile(outFilePath, [outFileName, '.mat']);

    if exist(outFileName, "file") && skipExist
        continue
    end

    if exist(outFileNameTemp, "file")
        delete(outFileNameTemp);
    end

    if verbose
        fprintf('unpack: %s\nto: %s\n', inFileNames{i}, outFileName);
    end

    timestampFullFile = fullfile(outFilePath, [timestampFileName, '_', suffix{i}]);

    if strcmp(ext, '.ncs')
        [signal, ADBitVolts, timeStamps, samplingInterval, ~] = Nlx_readCSC(inFileNames{i}, computeTS(i), outFilePath);
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
    
        if computeTS(i)
            matobj = matfile(timestampFullFile, Writable=true);
            matobj.timeStamps = timeStamps;
            matobj.samplingInterval = samplingInterval;
            matobj.samplingIntervalSeconds = seconds(samplingInterval);
            matobj.time0 = 0;
            matobj.timeend = timeend;
            matobj.timeendSeconds = seconds(timeend);
        end
    elseif strcmp(ext, '.nev')
        [timeStamps, TTLs, header] = Nlx2MatEV_v3(inFileNames{i}, [1 0 1 0 0], 1,1,[]);
        dt = diff(timeStamps);
        inds = find(dt<50 & dt>0);
        TTLs(inds) = [];
        timeStamps(inds) = [];
        timeStamps = timeStamps*1e-6; % convert timestamps to seconds.

        matobj = matfile(outFileNameTemp, 'Writable', true);
        matobj.TTLs = TTLs;
        matobj.timestamps = timeStamps;
        matobj.header = header;
    end

    movefile(outFileNameTemp, outFileName);
end

