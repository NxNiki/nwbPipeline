function unpackData(inFileNames, outFileNames, outFilePath, verbose, skipExist)
% unpackData(inFileNames, outFilePath, verbose): read neuralynx file and
% save to .mat files.

% inFileName: datatable(m, 1). '.ncs' files for one experiment. Should have same
% timestamps.

% timestamps: Unix time
% samplingInterval: matlab duration object.
% samplingRate can be calculate as: seconds(1)/samplingInterval.

% This function uses library developed by Ueli Rutishauser:
% https://www.urut.ch/new/serendipity/index.php?/pages/nlxtomatlab.html
% As this function calls mex files complied in intel/amd machine, it will
% not work on mac with Matlab >= 2023b which run natively on apple silicon.


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

% unpack the remainning files without computing the timestamp:
parfor i = 1:length(inFileNames)
    inFileName = inFileNames{i};
    [~, outFileName, ~] = fileparts(outFileNames{i});
    outFileName = fullfile(outFilePath, [outFileName, '.mat']);

    % TO DO: check if file is complete:
    if exist(outFileName, "file") && skipExist
        continue
    end

    if verbose
        fprintf('unpack: %s\n to %s\n', inFileName, outFileName);
    end

    timestampFullFile = fullfile(outFilePath, [timestampFileName, '_', suffix{i}]);

    [signal, timeStamps, samplingInterval, ~] = Nlx_readCSC(inFileNames{i}, computeTS(i), outFilePath);
    num_samples = length(signal);
    timeend = (num_samples-1) * samplingInterval;

    matobj = matfile(outFileName, 'Writable', true);
    matobj.samplingInterval = samplingInterval;
    matobj.data = signal;
    matobj.time0 = 0;
    matobj.timeend = timeend;

    if computeTS(i)
        matobj = matfile(timestampFullFile, Writable=true);
        matobj.timeStamps = timeStamps;
        matobj.samplingInterval = samplingInterval;
        matobj.time0 = 0;
        matobj.timeend = timeend;
    end
end

