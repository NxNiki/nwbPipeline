% remove raw CSC data in directories:
% keep spike and times files.

base_path = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm';
directories = {
    '511_MovieParadigm/Experiment8/CSC_data';
    '513_MovieParadigm/Experiment13/CSC_data';
    '513_MovieParadigm/Experiment6/CSC_data';
    '514_MovieParadigm/Experiment3/CSC_data';
    '515_MovieParadigm/Experiment15/CSC_data';
    '515_MovieParadigm/Experiment16/CSC_data';
    '517_MovieParadigm/Experiment3/CSC_data';
    '518_MovieParadigm/Experiment9/CSC_data';
    '524_MovieParadigm/Experiment4/CSC_data';
    '526_MovieParadigm/Experiment2/CSC_data';
    '526_MovieParadigm/Experiment8/CSC_data';
    '527_MovieParadigm/Experiment2/CSC_data';
    '529_MovieParadigm/Experiment2/CSC_data';
    '530_MovieParadigm/Experiment20/CSC_data';
    '530_MovieParadigm/Experiment8/CSC_data';
    '537_MovieParadigm/Experiment4/CSC_data';
    '539_MovieParadigm/Experiment4/CSC_data';
    '539_MovieParadigm/Experiment4/CSC_data/old';
    '539_MovieParadigm/Experiment5/CSC_data';
    '539_MovieParadigm/Experiment5/CSC_data/old';
    '539_MovieParadigm/Experiment6/CSC_data';
    '539_MovieParadigm/Experiment6/CSC_data/old';
    '541_MovieParadigm/Experiment12/CSC_data';
    '545_MovieParadigm/Experiment15/CSC_data';
    '545_MovieParadigm/Experiment17/CSC_data';
    '545_MovieParadigm/Experiment26/CSC_data';
    '545_MovieParadigm/Experiment30/CSC_data';
    '549_MovieParadigm/Experiment11/CSC_data';
    '549_MovieParadigm/Experiment9/CSC_data';
    '550_MovieParadigm/Experiment3/CSC_data';
    '550_MovieParadigm/Experiment4/CSC_data';
    '551_MovieParadigm/Experiment5/CSC_data';
    '552_MovieParadigm/Experiment4/CSC_data';
    '552_MovieParadigm/Experiment5/CSC_data';
    '555_MovieParadigm/Experiment-3/CSC_data';
    '555_MovieParadigm/Experiment-4/CSC_data';
    '555_MovieParadigm/Experiment-5/CSC_data';
    '557_MovieParadigm/Experiment11/CSC_data';
    '557_MovieParadigm/Experiment12/CSC_data';
    '557_MovieParadigm/Experiment13/CSC_data';
};


for i = 1:length(directories)

    files = dir(fullfile(base_path, directories{i}, '*.mat'));

    for j = 1:length(files)
        if startsWith(files(j).name, 'times_') || endsWith(files(j).name, '_spikes.mat')
            continue;
        end
        
        fprintf('delete: %s\n', fullfile(files(j).folder, files(j).name));
        delete(fullfile(files(j).folder, files(j).name));
    end
end
