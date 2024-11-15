% check number of spikes in times_manual* file.
% this is used to check if the micro channels for 563 with strange names
% (e.g. microA4) has spike or not.

spike_path = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/563_MovieParadigm/Experiment-10-11-12/CSC_micro_spikes';
% check_file_path(spike_path, "times_manual_G*-micro*.mat", 1, 1)
check_file_path(spike_path, "times_G*-micro*.mat", 0, 1)
check_file_path(spike_path, "G*-micro*.mat", 0, 1)


file_path = {
    '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/563_MovieParadigm/Experiment-10/CSC_micro';
    '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/563_MovieParadigm/Experiment-11/CSC_micro';
    '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/563_MovieParadigm/Experiment-12/CSC_micro';
    '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/563_MovieParadigm/Experiment-10-11-12/CSC_micro_spikes';
    };


for i = 1: length(file_path)
    check_file_path(spike_path(i), "G*-micro*.mat", 0, 1);
end

function check_file_path(file_path, file_pattern, count_spikes, move_file)
    files = dir(fullfile(file_path, file_pattern));
    backup_dir = fullfile(file_path, "backup");
    
    if ~exist(backup_dir, "dir") && move_file
        mkdir(backup_dir);
    end
    
    for i = 1:length(files)
        file = files(i);
        file_obj = matfile(fullfile(file.folder, file.name));
    
        if count_spikes
            cluster_class = file_obj.cluster_class;
            spike_count = sum(find(cluster_class(:, 1)>0));
            fprintf('%s: spikes: %d\n', file.name, spike_count);
        end
        
        if move_file
            fprintf('move file to backup folder: %s\n', fullfile(file.folder, file.name));
            movefile(fullfile(file.folder, file.name), fullfile(backup_dir, file.name));
        end
    end
end