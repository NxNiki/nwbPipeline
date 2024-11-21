% extract meta information from spike files.

% t0_unix
% exp0 (experiment number of first experiment, int), 
% time_unit (seconds)


exp_path = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm';
patient_ids = [555: 577];
% patient_ids = [555: 555];

skipExist = true;


for i = 1: length(patient_ids)
    patient_path = fullfile(exp_path, [num2str(patient_ids(i)), '_MovieParadigm']);
    if ~exist(patient_path, "dir")
        continue;
    end

    spike_path = find_matching_dirs(fullfile(patient_path, 'Experiment-*/CSC_micro_spikes'));

    for j = 1:length(spike_path)
        output_file = [spike_path{j}, '_meta.json'];

        if exist(output_file, "file") && skipExist
            continue;
        end

        first_exp_id = getExpId(spike_path{j});
        csc_path = fullfile(patient_path, sprintf('Experiment-%d', first_exp_id), 'CSC_micro');
        
        tsFile = fullfile(csc_path, 'lfpTimeStamps_001.mat');
        if ~exist(tsFile, "file")
            warning('file: %s not exist.', tsFile)
            continue;
        end
        timestampsFile = matfile(tsFile);

        meta_data = struct();
        meta_data.t0_unix = sprintf('%.6f', timestampsFile.timeStamps(1,1));
        meta_data.exp0 = first_exp_id;
        meta_data.time_unit = 'seconds';

        writeJson(meta_data, output_file)

    end
end


function expId = getExpId(filePath)
    match = regexp(filePath, 'Experiment-(\d+)', 'tokens');

    if ~isempty(match)
        expId = str2double(match{1}{1}); % Convert the matched number to double
    else
        warning('No expId found in: %s', filePath);
        expId = NaN;
    end
end


function matching_dirs = find_matching_dirs(pattern)
    % Find all directories matching a specific pattern.
    %
    % Parameters:
    %   pattern (string): The full pattern to match, e.g., '/path/Experiment-*/CSC_micro_spikes'.
    %
    % Returns:
    %   matching_dirs (cell array): List of matching directories.

    % Get all matching entries
    entries = dir(pattern);

    % Filter to include only directories
    is_dir = [entries.isdir];
    matching_dirs = {entries(is_dir).folder}; % Get the folder paths of matching directories

    % Ensure unique paths
    matching_dirs = unique(matching_dirs);
    matching_dirs = matching_dirs(:);
end
