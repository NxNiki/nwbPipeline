clear

scriptDir = fileparts(mfilename('fullpath'));
addpath(genpath(fileparts(scriptDir)));
cd(scriptDir)

expFilePath = 'neuralynx';
outFilePath = fullfile(scriptDir, expFilePath, 'nwb');
outNwbFile = fullfile(outFilePath, 'ecephys.nwb');

if ~exist(outFilePath, "dir")
    mkdir(outFilePath);
end

%% read timestamp files and init nwb:

date = '1900-01-01'; % Provide default DEFULT_DATA to protect PHI. Note: This DEFULT_DATA is not the ACTUAL DEFULT_DATA of the experiment
sessionStartTime = datetime(date,'Format','yyyy-MM-dd', 'TimeZone', 'local');

% generateCore('2.6.0');

nwb = NwbFile( ...
    'session_description', ['sub-001', '_exp-01', '_' 'test'],...
    'identifier', ['sub-001', '_exp-01', '_' 'test'], ...
    'session_start_time', sessionStartTime, ...
    'timestamps_reference_time', sessionStartTime);

subject = types.core.Subject( ...
    'subject_id', '001', ...
    'age', '', ...
    'description', '', ...
    'species', 'human', ...
    'sex', 'M' ...
);
nwb.general_subject = subject;

outNwbFileTemp = saveNWB(nwb, outNwbFile, 0);

%% micro and macro LFP:
samplingRate = 2000;

tic
[electrode_table_region_micro, electrode_table_region_macro] = createElectrodeTable(outNwbFileTemp, expFilePath);
saveLFPToNwb(outNwbFileTemp, expFilePath, samplingRate, electrode_table_region_micro, 'LFP_micro');
saveLFPToNwb(outNwbFileTemp, expFilePath, samplingRate, electrode_table_region_macro, 'LFP_macro');
toc

%% spikes:

tic
saveSpikesToNwb(outNwbFileTemp, expFilePath);
toc

%% finish writing to nwb:
saveNWB([], outNwbFile, 2);
