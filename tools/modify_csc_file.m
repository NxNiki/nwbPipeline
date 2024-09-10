% clear signalRemovePLI in csc files to save storage.

clear
search_path = {
    % '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/1741_MovieParadigm';
    '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/570_MovieParadigm';
    '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/573_MovieParadigm';
};

for i_path = 1: length(search_path)
    files = dir(fullfile(search_path{i_path}, '**/CSC_micro/G*.mat'));


    for i = 1:length(files)
        path = files(i).folder;
        fname = files(i).name;
        filePath = fullfile(path, fname);

        matFileObj = matfile(filePath, "Writable", true);

        fprintf("csc file: %s\n", filePath);
        matFileObj.signalRemovePLI = [];
    end

end
