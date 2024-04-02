function unpackData(inFileNames, outFilePath, verbose)
% unpackData(inFileName, outFileName): read neuralynx file and save to .mat
% files.

% This function uses library developed by Ueli Rutishauser:
% https://www.urut.ch/new/serendipity/index.php?/pages/nlxtomatlab.html
% As this function calls mex files complied in intel/amd machine, it will
% not work on mac with Matlab >= 2023b which run natively on apple silicon.




if nargin < 3
    verbose = 1;
end

parfor i = 1:length(inFileNames)
    inFileName = inFileNames{i};
    [~, filename, ~] = fileparts(inFileName);
    outFileName = fullfile(outFilePath, [filename, '.mat']);
    

    if verbose == 1
        fprintf('unpack: %s\n', inFileName);
    end

    [timeStamps, channelNumber, sampleFrequency, numSamples, signal, header] = Nlx2MatCSC_v3(inFileName, FieldSelection, ExtractHeader, ExtractMode, ModeArray);
    
    matobj = matfile(outFileName, 'Writable', true);
    matobj.timeStamps = timeStamps;
    matobj.channelNumber = channelNumber;
    matobj.sampleFrequency = sampleFrequency;
    matobj.numSamples = numSamples;
    matobj.signal = signal;
    matobj.header = header;

    % save(outFileName, 'timeStamps','channelNumber', 'sampleFrequency', 'numSamples', 'signal', 'header', '-v7.3');
end

