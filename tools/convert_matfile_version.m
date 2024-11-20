% check .mat file version and convert to v7.3 if not.

% search_path = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/570_MovieParadigm/Experiment-4-5-6-7/CSC_micro_spikes';
% search_path = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/567_MovieParadigm/Experiment-6-7-8-9-10/CSC_micro_spikes';
search_path = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm';


mat_files = dir(fullfile(search_path, "**", "CSC_micro_spikes/times_manual_*.mat"));

for i = 1:length(mat_files)
    if contains(mat_files(i).name, '_non73.mat')
        continue
    end
    mat_file = fullfile(mat_files(i).folder, mat_files(i).name);
    convertToV73(mat_file);
end

