function unpackData(inFileNames, outFileNames, outFilePath, verbose, skipExist)
% unpackData(inFileNames, outFilePath, verbose): read neuralynx file and
% save to .mat files.

% inFileName: datatable(m, 1). '.ncs' files for one experiment. Should have same
% timestamps.

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

% TO DO: probably don't want to hard code timestamp file name.
timestampFileName = 'lfpTimeStamps';

% unpack the remainning files without computing the timestamp:
parfor i = 1:length(inFileNames)
    inFileName = inFileNames{i};
    [~, outFileName, ~] = fileparts(outFileNames{i});
    outFileName = fullfile(outFilePath, [outFileName, '.mat']);
    if exist(outFileName, "file") && skipExist
        continue
    end

    if verbose
        fprintf('unpack: %s\n', inFileName);
    end

    suffix = regexp(outFileName, '(?<=_)\d{3}.mat', 'match', 'once');
    timestampFullFile = fullfile(outFilePath, [timestampFileName, suffix]);
    if ~exist(timestampFullFile, "file")
        computeTS = true;
    else
        computeTS = false;
    end

    [signal, timeStamps, samplingInterval, ~] = Nlx_readCSC(inFileNames{i}, computeTS, outFilePath);
    num_samples = length(signal);
    timeend = (num_samples-1) * (samplingInterval/1000); % in seconds

    matobj = matfile(outFileName, 'Writable', true);
    matobj.samplingInterval = samplingInterval;
    matobj.data = signal;
    matobj.time0 = 0;
    matobj.timeend = timeend;

    if computeTS
        matobj = matfile(timestampFullFile, Writable=true);
        matobj.timeStamps = timeStamps;
        matobj.samplingInterval = samplingInterval;
        matobj.time0 = 0;
        matobj.timeend = timeend;
    end

end

