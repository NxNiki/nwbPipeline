function combineNlxFiles(inputFiles, outputDir, outputFileNames, overWriteExistingFile, saveNlxFiles)
% combineNcsFiles: combine multiple .ncs/.nev files.
% Details:
%    This function combine .ncs/.nev files and save the combined files in
%    the outputDir. The order of files is assumed correct which is figured
%    out in previous step (groupFiles.m).
% 
% 
% Inputs:
%    inputFiles - cell [m n]. Each row is the name of a group of files to
%    be combined. If m or n is 1, all files are combined into one file.
%    Empty elements in cell array will be skipped.
%    
%
%    outputDir - string. The directory where combined files are saved.
%
%    outputFileNames - cell [m]. The name of the combined file. If this
%    is omited, the first column of inputFiles is used as the
%    outputFileNames.
%
%    overWriteExistingFile - boolean, default 1. 
%    1: if outputFileName exists, delete it and write a new file. 
%    0: append to existing file.
%
%    saveNlxFiles - boolean, default 0.
%    1: save combined .ncs/.nev files
%    0: only save .mat files.
% 
% Outputs:
%    combined .ncs/.nev file.
% 
% Example: 
%{ 
    inputFiles = {'temp/GA1-RA1.ncs', 'temp/GA1-RA1_0001.ncs'}; 
    outputDir = 'temp/combined/';
    outputFileName = 'GA1-RA1.ncs';
    combineNcsFiles(inputFiles, outputDir, outputFileName);
    
    inputFiles = {'temp/GA1-RA1.ncs', 'temp/GA1-RA1_0001.ncs'; 'temp/GA1-RA2.ncs', 'temp/GA1-RA2_0001.ncs'}; 
    outputDir = 'temp/combined/';
    outputFileName = {'GA1-RA1.ncs', 'GA1-RA2.ncs'};
    combineNcsFiles(inputFiles, outputDir, outputFileName);

    inputFiles = {'temp/GA1-RA1.ncs', ''; 'temp/GA1-RA2.ncs', 'temp/GA1-RA2_0001.ncs'}; 
    outputDir = 'temp/combined/';
    outputFileName = {'GA1-RA1.ncs', 'GA1-RA2.ncs'};
    combineNcsFiles(inputFiles, outputDir);
%}
% See also: Nlx2MatCSC_v3, Mat2NlxCSC, groupFiles

% Author:                          Xin Niu
% Email:                           xinniu@mednet.ucla.edu
% Version history revision notes:
%   created by Xin based on Chris Dao's work. Feb-22-2024.


if ~exist(outputDir, "dir")
    mkdir(outputDir)
end

if nargin < 3
    outputFileNames = cellfun(@(x)getFileName(x), inputFiles(:, 1), 'UniformOutput', false);
end

if nargin < 4
    overWriteExistingFile = false;
end

if nargin < 5
    saveNlxFiles = true;
end

if ~iscell(outputFileNames)
    outputFileNames = {outputFileNames};
end

% assume all files have same extension:
[~, ~, fileExtension] = fileparts(inputFiles{1});

[numGroups, numFiles] = size(inputFiles);
for i = 1:numGroups  
    if saveNlxFiles
        outputPathName = [fullfile(outputDir, outputFileNames{i}), '.ncs'];
    else
        outputPathName = [fullfile(outputDir, outputFileNames{i}), '.mat'];
    end
    fprintf("combineNlxFiles: %s\n", outputPathName)

    if exist(outputPathName, "file") && overWriteExistingFile
        delete(outputPathName);
        fprintf("combineNlxFiles: existing file %s is deleted\n", outputPathName);
    elseif exist(outputPathName, "file")
        fprintf("combineNlxFiles: existing file %s is skipped\n", outputPathName);
        continue
    end

    if fileExtension == ".ncs"

        timeStamps = cell(1, numFiles);
        channelNumber = cell(1, numFiles);
        numSamples = cell(1, numFiles);
        sampleFrequency = cell(1, numFiles);
        signal = cell(1, numFiles);
        
        filesToCombine = inputFiles(i,:);
        filesToCombine = filesToCombine(~cellfun('isempty', filesToCombine));
        for j = 1: length(filesToCombine)
            if i == 1
                [timeStamps{j}, channelNumber{j}, sampleFrequency{j}, numSamples{j}, signal{j}, header] = Nlx2MatCSC_v3(filesToCombine{j},[1,1,1,1,1],1,1);
            else
                [timeStamps{j}, channelNumber{j}, sampleFrequency{j}, numSamples{j}, signal{j}, ~] = Nlx2MatCSC_v3(filesToCombine{j},[1,1,1,1,1],1,1);
            end
            
            % fill short signals with NaN:
            if size(signal{j}, 2) > 1
                toShorten = find(numSamples{j} ~= size(signal{j},1));
                for s = 1:length(toShorten)
                    signal{j}(numSamples{j}(toShorten(s))+1:end,toShorten(s)) = NaN;
                end
            end
        end
        
        if saveNlxFiles
            % we no longer consider this is necessary.
            Mat2NlxCSC( ...
                outputPathName, ...
                0, 1, 1, size([signal{:}],2), [1 1 1 1 1 1], ...
                [timeStamps{:}], ...
                [channelNumber{:}], ...
                [sampleFrequency{:}], ...
                [numSamples{:}], ...
                [signal{:}], ...
                header);
        else

            % save .mat files.
            timeStamps = [timeStamps{:}];
            channelNumber = [channelNumber{:}];
            sampleFrequency = [sampleFrequency{:}];
            numSamples = [numSamples{:}];
            signal = vertcat(signal{:});
            save(outputPathName, 'timeStamps','channelNumber', 'sampleFrequency', 'numSamples', 'signal', 'header', '-v7.3');
        end

    elseif fileExtension == ".nev"

        timeStamps = cell(1, numFiles);
        ttls = cell(1, numFiles);
        eventStrings = cell(1, numFiles);
        
        filesToCombine = inputFiles(i,:);
        filesToCombine = filesToCombine(~cellfun('isempty', filesToCombine));
        for j = 1: length(filesToCombine)
            if i == 1
                [timeStamps{j}, ttls{j}, eventStrings{i}, header] = Nlx2MatEV_v3(filesToCombine{i}, [1 0 1 0 1], 1,1,[]);
                
            else
                [timeStamps{j}, ttls{j}, eventStrings{i}, ~] = Nlx2MatEV_v3(filesToCombine{i}, [1 0 1 0 1], 1,1,[]);
            end
            timeStamps{j} = timeStamps{j}*1e-6; % convert to seconds
        end

        if saveNlxFiles
            % not finished...
            disp('combineNlxFiles: saveNlxFiles for events not implemented!')
        else
            % not finished...
            % save([outputPathName, '_events.mat'], 'timeStamps', 'ttls', 'eventStrings', 'header');
        end

    end
end
end

function fileName = getFileName(fullPath)
    [~, fileName, ~] = fileparts(fullPath);
end
