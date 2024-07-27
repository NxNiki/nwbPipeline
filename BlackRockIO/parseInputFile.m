function [samplingInterval, outputFilePath, electrodeInfoFileName] = parseInputFile(inFile, expFilePath)
% decide micro or macro and samplingInterval from file extension 
% (blackrock).


    [~, ~, ext] = fileparts(inFile);
    switch ext
        case '.ns5'
            sampFreq_hz = 30000; % neuroport_samp_freq_hz;
            outputFilePath = fullfile(expFilePath, 'CSC_micro');
        case '.ns2'
            sampFreq_hz = 1000;
            outputFilePath = fullfile(expFilePath, 'LFPXWide');
        case '.ns3'
            sampFreq_hz = 2000;
            outputFilePath = fullfile(expFilePath, 'CSC_macro');
        case '.ns4'
            sampFreq_hz = 10000;
            outputFilePath = fullfile(expFilePath, 'MACROBRfast');
    end

    electrodeInfoFileName = ['electrode_info_', strrep(ext, '.', ''), '.mat'];
    samplingInterval =  seconds(1) / sampFreq_hz;
end