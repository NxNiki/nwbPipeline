% It is recommend to use pynwb to export data to .nwb file, as pynwb has
% better tutorial, easier to install, and more widely used in the
% community.
% See run_export_nwb.py.

clear

scriptDir = fileparts(mfilename('fullpath'));
addpath(genpath(fileparts(scriptDir)));
cd(scriptDir)

Device = 'Neuralynx Pegasus';
manufacturer = 'Neuralynx';

expIds = (3:11);
expName = 'MovieParadigm';
patientId = 573;


filePath = sprintf('/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/%s/%d_%s', expName, patientId, expName);
expFilePath = fullfile(filePath, ['/Experiment', sprintf('-%d', expIds)]);
outFilePath = fullfile(expFilePath, 'nwb');
outNwbFile = fullfile(outFilePath, 'ecephys.nwb');

if ~exist(outFilePath, "dir")
    mkdir(outFilePath);
end
% generateCore('2.6.0');

%% read timestamp files and init nwb:

% timestampFiles = dir(fullfile(microFilePath, '/CSC_micro/lfpTimeStamps*.mat'));
% timestampFiles = fullfile(microFilePath, {timestampFiles.name});
% tsObj = matfile(timestampFiles{1});
% sessionStartTime = datetime(tsObj.timeStamps(1,1), 'convertfrom','posixtime', 'Format','dd-MMM-yyyy HH:mm:ss.SSS');

date = '1900-01-01'; % Provide default DEFULT_DATA to protect PHI. Note: This DEFULT_DATA is not the ACTUAL DEFULT_DATA of the experiment
sessionStartTime = datetime(date, 'Format', 'yyyy-MM-dd', 'TimeZone', 'local');

nwb = NwbFile( ...
    'session_description', ['sub-' num2str(patientId), '_exp', sprintf('-%d', expIds), '_' expName],...
    'identifier', ['sub-' num2str(patientId), '_exp', sprintf('-%d', expIds), '_' expName], ...
    'session_start_time', sessionStartTime, ...
    'timestamps_reference_time', sessionStartTime, ...
    'general_experimenter', 'My Name', ... % optional
    'general_session_id', '', ... % optional
    'general_institution', 'UCLA', ... % optional
    'general_related_publications', ''); % optional

nwb.general_subject = types.core.Subject( ...
    'subject_id', num2str(patientId), ...
    'age', '', ...
    'description', '', ...
    'species', 'human', ...
    'sex', 'M' ...
);

outNwbFileTemp = saveNWB(nwb, outNwbFile, 0);

%% save trials:

trials = combineTTL(filePath, expIds);
saveTTLToNwb(outNwbFileTemp, trials);

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

%% finished writing NWB file:

saveNWB([], outNwbFile, 2);
