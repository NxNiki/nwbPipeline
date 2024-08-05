function [electrode_table_region_micro, electrode_table_region_macro] = createElectrodeTable(nwbFile, expFilePath)
% create electrode table based on file names of micro and macro channels.
% micro channels have pattern: G[A-D][1-8]_[A-Z]+[1-8]_lfp.mat
% macro channels have pattern: [A-Z]+[1-8]_lfp.mat


    lfpFilePath = fullfile(expFilePath, 'LFP_micro');
    microLfpFiles = listFiles(lfpFilePath, '*_lfp.mat', '^\.');
    
    lfpFilePath = fullfile(expFilePath, 'LFP_macro');
    macroLfpFiles = listFiles(lfpFilePath, '*_lfp.mat', '^\._');

    if isempty(microLfpFiles) && isempty(macroLfpFiles)
        error('no LFP files detected!');
    end
    fprintf('createElectrodeTable: total of %d micro LFP file detected\n', length(microLfpFiles));
    fprintf('createElectrodeTable: total of %d macro LFP file detected\n', length(macroLfpFiles));

    Device = types.core.Device(...
    'description', 'Neuralynx', ...
    'manufacturer', 'Neuralynx' ...
    );

    nwb = nwbRead(nwbFile);
    nwb.general_devices.set('array', Device);

    lfpFiles = [microLfpFiles(:); macroLfpFiles(:)];
    
    ElectrodesDynamicTable = types.hdmf_common.DynamicTable(...
            'colnames', {'x', 'y', 'z', 'location', 'group', 'group_name', 'label'}, ...
            'description', 'all electrodes');

        pattern = '(G[A-D][1-8])|([A-Z]+[1-8])';
        shankLabelAdded = {};
        
        for i = 1:length(lfpFiles)
            
            [~, lfpFileName] = fileparts(lfpFiles{i});
            matches = regexp(lfpFileName, pattern, 'match');
    
            if length(matches) == 2
                shankLabel = matches{1};
                electrodeLabel = matches{2};
            else
                shankLabel = 'macro';
                electrodeLabel = matches{1};
            end
            location = regexp(electrodeLabel, '[A-Z]+', 'match');
            
            if ~ismember(shankLabel, shankLabelAdded) || isempty(shankLabelAdded)
                EGroup = types.core.ElectrodeGroup( ...
                    'description', sprintf('electrode group for %s', shankLabel), ...
                    'location', location{1}, ...
                    'device', types.untyped.SoftLink(Device) ...
                );
                nwb.general_extracellular_ephys.set(shankLabel, EGroup);
                shankLabelAdded = [shankLabelAdded, {shankLabel}];
            end
    
            ElectrodesDynamicTable.addRow( ...
                'x', 111, ...
                'y', 111, ...
                'z', 111, ...
                'location', location{1}, ...
                'group', types.untyped.ObjectView(EGroup), ...
                'group_name', shankLabel, ...
                'label', electrodeLabel);
        end
        
    ElectrodesDynamicTable.toTable()
    nwb.general_extracellular_ephys_electrodes = ElectrodesDynamicTable;

    if ~isempty(microLfpFiles)
        electrode_table_region_micro = types.hdmf_common.DynamicTableRegion( ...
            'table', types.untyped.ObjectView(ElectrodesDynamicTable), ...
            'description', 'micro electrodes', ...
            'data', (0: length(microLfpFiles)-1)');
    else
        electrode_table_region_micro = [];
    end

    if ~isempty(macroLfpFiles)
        electrode_table_region_macro = types.hdmf_common.DynamicTableRegion( ...
            'table', types.untyped.ObjectView(ElectrodesDynamicTable), ...
            'description', 'macro electrodes', ...
            'data', (length(microLfpFiles): length(lfpFiles)-1)');
    else
        electrode_table_region_macro = [];
    end

    % export nwb to save memory usage:
    saveNWB(nwb, nwbFile)
    
end
