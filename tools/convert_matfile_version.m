% check .mat file version and convert to v7.3 if not.

% search_path = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/570_MovieParadigm/Experiment-4-5-6-7/CSC_micro_spikes';
% search_path = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/567_MovieParadigm/Experiment-6-7-8-9-10/CSC_micro_spikes';
search_path = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm';

non73_backup_path = '/Users/XinNiuAdmin/Downloads/times_manual_non73_backup';


mat_files = dir(fullfile(search_path, "**", "CSC_micro_spikes/times_manual_*.mat"));

for i = 1:length(mat_files)
    
    mat_file = fullfile(mat_files(i).folder, mat_files(i).name);

    if contains(mat_files(i).name, '_non73.mat')
        % move to backup path:
        backup_path = strrep(mat_files(i).folder, search_path, non73_backup_path);
        if ~exist(backup_path, "dir")
            mkdir(backup_path);
        end
        fprintf('move file: %s\nto %s\n', mat_file, backup_path)
        movefile(mat_file, fullfile(backup_path, mat_files(i).name));
        continue
    end

    % convert file to version 7.3:
    % convertToV73(mat_file);
end

