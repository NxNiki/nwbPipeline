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

% unpack the first file with timestamp information:
computeTS = true;
% TO DO: probably don't want to hard code file name of timestamp.
timestampFileName = 'lfpTimeStamps.mat';
[data, timeStamps, samplingInterval, ~] = Nlx_readCSC(inFileNames{1}, computeTS);

num_samples = length(data);
samp_freq_hz = 1/samplingInterval*1000;

regularTimeStamps = 0:1/samp_freq_hz:((num_samples-1)*(1/samp_freq_hz));
time0 = 0; 
timeend = regularTimeStamps(end);

[~, filename, ~] = fileparts(inFileNames{1});
save(fullfile(outFilePath, [filename, '.mat']), 'data', 'samplingInterval', 'time0', 'timeend', '-v7.3');
save(fullfile(outFilePath, timestampFileName), 'timeStamps','time0','timeend','-v7.3');

% unpack the remainning files without computing the timestamp:
computeTS = false;
parfor i = 2:length(inFileNames)
    inFileName = inFileNames{i};
    [~, filename, ~] = fileparts(inFileName);
    outFileName = fullfile(outFilePath, [filename, '.mat']);

    if verbose == 1
        fprintf('unpack: %s\n', inFileName);
    end

    [signal, ~ , samplingInterval, ~] = Nlx_readCSC(fileName, computeTS)
    
    matobj = matfile(outFileName, 'Writable', true);
    matobj.samplingInterval = samplingInterval;
    matobj.data = signal;
    matobj.time0 = time0;
    matobj.timeend = timeend;
end

