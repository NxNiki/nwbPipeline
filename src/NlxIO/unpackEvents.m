function outFileNames = unpackEvents(inFileNames, outFileNames, outFilePath, verbose, skipExist)
if nargin < 4 || isempty(verbose)
    verbose = 1;
end

if nargin < 5
    skipExist = 1;
end

makeOutputPath(inFileNames, outFilePath, skipExist)

for i = 1:length(inFileNames)

    [~, outFileName, ~] = fileparts(outFileNames{i});
    outFileNameTemp = fullfile(outFilePath, [outFileName, 'temp.mat']);
    outFileName = fullfile(outFilePath, [outFileName, '.mat']);

    if skipExist && exist(outFileName, "file") && checkMatFileCorruption(outFileName) 
        continue
    end

    if exist(outFileNameTemp, "file")
        warning('delete temp file: %s\n', outFileNameTemp);
        delete(outFileNameTemp);
    end

    if verbose
        fprintf('unpack event file: %s\nto: %s\n', inFileNames{i}, outFileName);
    end

    [timetamps, TTLs, header] = Nlx2MatEV_v3(inFileNames{i}, [1 0 1 0 0], 1,1,[]);
    dt = diff(timetamps);
    inds = find(dt<50 & dt>0);
    TTLs(inds) = [];
    timetamps(inds) = [];
    timetamps = timetamps*1e-6; % convert timestamps to seconds.
    
    matobj = matfile(outFileNameTemp, 'Writable', true);
    matobj.TTLs = TTLs;
    matobj.timestamps = timetamps;
    matobj.header = header;
    
    movefile(outFileNameTemp, outFileName);
    outFileNames{i} = outFileName;

end