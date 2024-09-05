% copy timestampsStart from times_* file to times_manual_* files.

clear
search_path = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/';
files = dir(fullfile(search_path, '**/times_manual*.mat'));

for i = 1:length(files)
    path = files(i).folder;
    fname = strrep(files(i).name, 'times_manual_', 'times_');
    timesFile = fullfile(path, fname);

    load(timesFile, 'timestampsStart');

    fprintf("times file: %s\n", timesFile);
    fprintf("times manual file: %s\n", fullfile(path, files(i).name));

    save(fullfile(path, files(i).name), 'timestampsStart', '-append');
end
