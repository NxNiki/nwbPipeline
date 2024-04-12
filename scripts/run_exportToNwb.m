% export csc, spikes, lfp, etc to .nwb file.

% https://neurodatawithoutborders.github.io/matnwb/tutorials/html/intro.html#H_FF8B1A2D
% https://neurodatawithoutborders.github.io/matnwb/tutorials/html/ecephys.html


expId = 1;
filePath = '/Users/XinNiuAdmin/Documents/NWBTest/output/Screening/550_Screening';

% expId = 5;
% filePath = '/Users/XinNiuAdmin/Documents/NWBTest/inputNLX/D570/EXP5_Movie_24_Sleep/2024-01-27_00-01-35';
% outFilePath = '/Users/XinNiuAdmin/Documents/NWBTest/output/MovieParadigm/570_MovieParadigm';

% 0: will remove all previous unpack files.
% 1: skip existing files.
skipExist = 1; 

outFilePath = [filePath, sprintf('/Experiment%d/nwb', expId)];

if ~exist(outFilePath, "dir")
    mkdir(outFilePath);
end

%% read timestamp files and init nwb:

microFilePath = fullfile(filePath, sprintf('/Experiment%d/CSC_micro', expId));
timestampFiles = dir(fullfile(microFilePath, 'lfpTimeStamps*.mat'));
timestampFiles = fullfile(microFilePath, {timestampFiles.name});

tsObj = matfile(timestampFiles{1});
sessionStartTime = datetime(tsObj.timeStamps(1,1), 'convertfrom','posixtime', 'Format','dd-MMM-yyyy HH:mm:ss.SSS');

generateCore('2.6.0');

nwb = NwbFile( ...
    'session_description', 'sub-550_exp-1_Screening',...
    'identifier', 'sub-550_exp-1_Screening', ...
    'session_start_time', sessionStartTime, ...
    'timestamps_reference_time', sessionStartTime, ...
    'general_experimenter', 'My Name', ... % optional
    'general_session_id', 'session_1234', ... % optional
    'general_institution', 'University of My Institution', ... % optional
    'general_related_publications', 'DOI:10.1016/j.neuron.2016.12.011'); % optional

subject = types.core.Subject( ...
    'subject_id', '550', ...
    'age', '', ...
    'description', '', ...
    'species', 'human', ...
    'sex', 'M' ...
);
nwb.general_subject = subject;

%% Electrodes Table:
numShanks = 1;
numChannelsPerShank = 4;
 
ElectrodesDynamicTable = types.hdmf_common.DynamicTable(...
    'colnames', {'location', 'group', 'group_name', 'label'}, ...
    'description', 'all electrodes');
 
Device = types.core.Device(...
    'description', 'Neuralynx Pegasus', ...
    'manufacturer', 'Neuralynx' ...
);

shankLabel = {'GA'};
electrodeLabel = {'ROF'};

nwb.general_devices.set('array', Device);
for iShank = 1:numShanks
    shankGroupName = sprintf([shankLabel{iShank}, '%d'], iShank);
    EGroup = types.core.ElectrodeGroup( ...
        'description', sprintf('electrode group for %s', shankGroupName), ...
        'location', 'brain area', ...
        'device', types.untyped.SoftLink(Device) ...
    );
    
    nwb.general_extracellular_ephys.set(shankGroupName, EGroup);
    for iElectrode = 1:numChannelsPerShank
        ElectrodesDynamicTable.addRow( ...
            'location', 'unknown', ...
            'group', types.untyped.ObjectView(EGroup), ...
            'group_name', shankGroupName, ...
            'label', sprintf(['%s-', electrodeLabel{iShank}, '%d'], shankGroupName, iElectrode));
    end
end
ElectrodesDynamicTable.toTable()

%%  Electrical Series:

microFilePath = fullfile(expFilePath, 'CSC_micro');
microFiles = readcell(fullfile(microFilePath, 'outFileNames.csv'), Delimiter=",");

voltageSignals = cell(1, length(microFiles));
for i = 1: length(microFiles)
    [voltageSignals{i}, ~, samplingInterval] = combineCSC(microFiles(i,:), timestampFiles);
end
voltageSignal = [voltageSignals{:}];

electrode_table_region = types.hdmf_common.DynamicTableRegion( ...
    'table', types.untyped.ObjectView(ElectrodesDynamicTable), ...
    'description', 'all electrodes', ...
    'data', (0:length(ElectrodesDynamicTable.id.data)-1)');

electrical_series = types.core.ElectricalSeries( ...
    'starting_time', 0.0, ... % seconds
    'starting_time_rate', 1/samplingInterval, ... % Hz
    'data', voltageSignal, ...
    'electrodes', electrode_table_region, ...
    'data_unit', 'volts');
nwb.acquisition.set('ElectricalSeries', electrical_series);

%%

lfpFilePath = fullfile(filePath, sprintf('/Experiment%d/LFP_micro', expId));
lfpFiles = dir(fullfile(lfpFilePath, '*_lfp.mat'));
lfpFiles = fullfile(lfpFilePath, {lfpFiles.name});

lfpSignals = cell(1, length(lfpFiles));
for i = 1: length(lfpFiles)
    lfpObj = matfile(lfpFiles(i,:));
    lfpSignals{i} = lfpObj.lfp;
end
lfpSignal = [lfpSignals{:}];

% LFP:
electrical_series = types.core.ElectricalSeries( ...
    'starting_time', 0.0, ... % seconds
    'starting_time_rate', 2000., ... % Hz
    'data', lfpSignal, ...
    'electrodes', electrode_table_region, ...
    'data_unit', 'volts');
 
lfp = types.core.LFP('ElectricalSeries', electrical_series);
 
ecephys_module = types.core.ProcessingModule(...
    'description', 'extracellular electrophysiology');
 
ecephys_module.nwbdatainterface.set('LFP', lfp);
nwb.processing.set('ecephys', ecephys_module);

%% 

nwbExport(nwb, 'ecephys_tutorial.nwb')

