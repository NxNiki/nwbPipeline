function cleanCorruptedMatFiles(filePath)
% check .mat files in filePath is corrupted. if yes, remove them.

files = dir(fullfile(filePath, '*.mat'));

for i = 1:length(files)
    filename = fullfile(files(i).folder, files(i).name);

    try
        obj = matfile(filename);
    catch err
        disp(err)
        fprintf('delete corrupted file: %s\n', filename);
        delete(filename);
    end
end
