function fileNameTmp = saveNWB(nwb, fileName, stage, removeExist)
% removeExist is used to avoid conflicting with previous saved data. It
% takes effects only when you save a new nwb file (stage 0).
% Otherwise, deleting existing nwb file will cause error in nwbExport due
% to lazy loading.
% stage: int value to indicate stage of nwb export.
%   0: create a new file
%   1: add data to existing file
%   2: finish data export. (if nwb is empty, will only rename the file).


    if nargin < 3
        if ~exist(fileName, "file")
            stage = 0;
        elseif isempty(nwb)
            stage = 2;
        else
            stage = 1;
        end
    end

    if nargin < 4
        removeExist = 1;
    end

    switch stage
        case 0
            fileNameTmp = strrep(fileName, '.nwb', '_tmp.nwb');
            if exist(fileNameTmp, "file") && removeExist
                delete(fileNameTmp);
                fprintf('delete existing nwb file: %s.\n', fileNameTmp);
            end
            nwbExport(nwb, fileNameTmp);

        case 1
            if endsWith(fileName, '_tmp.nwb')
                fileNameTmp = fileName;
            else
                fileNameTmp = strrep(fileName, '.nwb', '_tmp.nwb');
            end

            fprintf('add data to nwb: %s\n', fileNameTmp);
            nwbExport(nwb, fileNameTmp);

        case 2
            if endsWith(fileName, '_tmp.nwb')
                fileNameTmp = fileName;
                fileName = strrep(fileName, '_tmp.nwb', '.nwb');
            else
                fileNameTmp = strrep(fileName, '.nwb', '_tmp.nwb');
            end

            if ~isempty(nwb)
                nwbExport(nwb, fileNameTmp);
            end

            fprintf('finish writing nwb:\n move: %s\n to: %s\n', fileNameTmp, fileName);
            movefile(fileNameTmp, fileName);
            fileNameTmp = fileName;
    end

end
