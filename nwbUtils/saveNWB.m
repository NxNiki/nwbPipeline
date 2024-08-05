function saveNWB(nwb, fileName, stage)
% removeExist is used to avoid conflicting with previous saved data. Use
% this only when you save a new nwb file (with all fields loaded).
% Otherwise, deleting existing nwb file will cause error in nwbExport due
% to lazy loading.
% stage: int value to indicate stage of nwb export.
%   0: create a new file
%   1: add data to existing file (default)
%   2: finish data export. (if nwb is empty, will only rename the file).

    
    if nargin < 3
        stage = 1;
    end

    fileNameTmp = strrep(fileName, '.nwb', '_tmp.nwb');

    if exist(fileNameTmp, "file") && stage == 0
        delete(fileNameTmp);
        fprintf('delete existing nwb file: %s.\n', fileNameTmp);
    end

    if ~isempty(nwb)
        fprintf('add data to nwb: %s\n', fileNameTmp);
        nwbExport(nwb, fileNameTmp);
    end

    if stage == 2
        movefile(fileNameTmp, fileName);
    end

end