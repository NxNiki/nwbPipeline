clear

scriptDir = fileparts(mfilename('fullpath'));
addpath(genpath(fileparts(scriptDir)));
cd(scriptDir)

Device = 'Neuralynx Pegasus';
manufacturer = 'Neuralynx';

expIds = (3:11);
expName = 'MovieParadigm';
patientId = 573;
filePath = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/573_MovieParadigm';


expFilePath = fullfile(filePath, ['/Experiment', sprintf('-%d', expIds)]);
outFilePath = fullfile(expFilePath, 'nwb');
outNwbFile = fullfile(outFilePath, 'ecephys.nwb');

if ~exist(outFilePath, "dir")
    mkdir(outFilePath);
end

%% read timestamp files and init nwb:

% timestampFiles = dir(fullfile(microFilePath, '/CSC_micro/lfpTimeStamps*.mat'));
% timestampFiles = fullfile(microFilePath, {timestampFiles.name});
% tsObj = matfile(timestampFiles{1});
% sessionStartTime = datetime(tsObj.timeStamps(1,1), 'convertfrom','posixtime', 'Format','dd-MMM-yyyy HH:mm:ss.SSS');

date = '1900-01-01'; % Provide default date to protect PHI. Note: This date is not the ACTUAL date of the experiment 
sessionStartTime = datetime(date,'Format','yyyy-MM-dd', 'TimeZone', 'local');

% generateCore('2.6.0');

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

saveNWB(nwb, outNwbFile, 1)

%% micro and macro LFP:
samplingRate = 2000;

tic
[electrode_table_region_micro, electrode_table_region_macro] = createElectrodeTable(outNwbFile, expFilePath);
saveLFPToNwb(outNwbFile, expFilePath, samplingRate, electrode_table_region_micro, 'LFP_micro');
saveLFPToNwb(outNwbFile, expFilePath, samplingRate, electrode_table_region_macro, 'LFP_macro');
toc

%% spikes:

tic
saveSpikesToNwb(outNwbFile, expFilePath)
toc