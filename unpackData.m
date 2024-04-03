function unpackData(inFileNames, outFilePath, verbose)
% unpackData(inFileNames, outFilePath, verbose): read neuralynx file and 
% save to .mat files. 

% inFileName: cell(n, 1). '.ncs' files for one experiment. Should have same
% timestamps.

% This function uses library developed by Ueli Rutishauser:
% https://www.urut.ch/new/serendipity/index.php?/pages/nlxtomatlab.html
% As this function calls mex files complied in intel/amd machine, it will
% not work on mac with Matlab >= 2023b which run natively on apple silicon.


if nargin < 3
    verbose = 1;
end

if verbose
    fprintf('unpack the first file: %s with timestamp information...\n', inFileNames{1});
end
computeTS = true;
% TO DO: probably don't want to hard code timestamp file name.
timestampFileName = 'lfpTimeStamps.mat';
[data, timeStamps, samplingInterval, ~] = Nlx_readCSC(inFileNames{1}, computeTS, outFilePath);

num_samples = length(data);
time0 = 0; 
timeend = (num_samples-1) * (samplingInterval/1000); % in seconds

[~, filename, ~] = fileparts(inFileNames{1});
save(fullfile(outFilePath, [filename, '.mat']), 'data', 'samplingInterval', 'time0', 'timeend', '-v7.3');
save(fullfile(outFilePath, timestampFileName), 'timeStamps', 'samplingInterval', 'time0', 'timeend', '-v7.3');

% unpack the remainning files without computing the timestamp:
computeTS = false;
parfor i = 2:length(inFileNames)
    inFileName = inFileNames{i};
    [~, filename, ~] = fileparts(inFileName);
    outFileName = fullfile(outFilePath, [filename, '.mat']);

    if verbose
        fprintf('unpack: %s\n', inFileName);
    end

    [signal, ~ , samplingInterval, ~] = Nlx_readCSC(inFileName, computeTS)
    matobj = matfile(outFileName, 'Writable', true);
    matobj.samplingInterval = samplingInterval;
    matobj.data = signal;
    matobj.time0 = time0;
    matobj.timeend = timeend;
end

