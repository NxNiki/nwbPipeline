function unpackData(inFileNames, outFileNames, outFilePath, verbose)
% unpackData(inFileNames, outFilePath, verbose): read neuralynx file and
% save to .mat files.

% inFileName: datatable(m, 1). '.ncs' files for one experiment. Should have same
% timestamps.

% This function uses library developed by Ueli Rutishauser:
% https://www.urut.ch/new/serendipity/index.php?/pages/nlxtomatlab.html
% As this function calls mex files complied in intel/amd machine, it will
% not work on mac with Matlab >= 2023b which run natively on apple silicon.


if nargin < 4
    verbose = 1;
end

if verbose
    fprintf('unpack the first file: %s with timestamp information...\n', inFileNames{1});
end

% TO DO: probably don't want to hard code timestamp file name.
timestampFileName = 'lfpTimeStamps';

% unpack the remainning files without computing the timestamp:
for i = 2:length(inFileNames)
    inFileName = inFileNames{i};
    [~, outFileName, ~] = fileparts(outFileNames{i});
    outFileName = fullfile(outFilePath, [outFileName, '.mat']);
    suffix = regexp(outFileName, '(?<=_)\d{3}.mat', 'match', 'once');

    if verbose
        fprintf('unpack: %s\n', inFileName);
    end

    timestampFullFile = fullfile(outFilePath, [timestampFileName, suffix]);
    if ~exist(timestampFullFile, "file")
        computeTS = true;

    else
        computeTS = false;
    end
    [~, timeStamps, samplingInterval, ~] = Nlx_readCSC(inFileNames{1}, computeTS, outFilePath);
    num_samples = length(data);
    time0 = 0;
    timeend = (num_samples-1) * (samplingInterval/1000); % in seconds

    matobj = matfile(outFileName, 'Writable', true);
    matobj.samplingInterval = samplingInterval;
    matobj.data = signal;
    matobj.time0 = time0;
    matobj.timeend = timeend;

    if computeTS
        matobj = matfile(timestampFullFile, Writable=true);
        matobj.timeStamps = timeStamps;
        matobj.samplingInterval = samplingInterval;
        matobj.time0 = time0;
        matobj.timeend = timeend;
    end

end

