function saveNWB(nwb, fileName, removeExist)
% removeExist is used to avoid conflicting with previous saved data. Use
% this only when you save a new nwb file (with all fields loaded).
% Otherwise, deleting existing nwb file will cause error in nwbExport due
% to lazy loading.

    
    if nargin < 3
        removeExist = 0;
    end
    
    if exist(fileName, "file") && removeExist

        delete(fileName);
        fprintf('delete existing nwb file.\n');
    end

    fprintf('save data to nwb: %s\n', fileName);
    nwbExport(nwb, fileName);

end