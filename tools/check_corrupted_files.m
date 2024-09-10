% check if .mat file is corrupted.
% the corrupted files will be renamed so that you can run the pipeline with
% skipExist set to true to recreated the corrupted files.


clear
search_path = {
    '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/557_MovieParadigm/Experiment-12';
};

for i_path = 1: length(search_path)
    files = dir(fullfile(search_path{i_path}, '**/CSC_micro/G*.mat'));


    for i = 1:length(files)
        path = files(i).folder;
        fname = files(i).name;
        filePath = fullfile(path, fname);

        try
            matFileObj = matfile(filePath, "Writable", false);
        catch
            fprintf("corrupted file: %s\n", filePath);
            movefile(filePath, strrep(filePath, '.mat', '_corrupted.mat'));
        end
    end

end
