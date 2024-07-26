function [nwb, electrode_table_region] = createElectrodeTable(nwb, lfpFiles, Device)
% create electrode table based on file names of micro and macro channels.
% micro channels have pattern: G[A-D][1-8]_[A-Z]+[1-8]_lfp.mat
% macro channels have pattern: [A-Z]+[1-8]_lfp.mat


    if isempty(lfpFiles)
        error('no LFP files detected!');
    end

    ElectrodesDynamicTable = types.hdmf_common.DynamicTable(...
        'colnames', {'x', 'y', 'z', 'location', 'group', 'group_name', 'label'}, ...
        'description', 'all electrodes');
    
    nwb.general_devices.set('array', Device);
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

    electrode_table_region = types.hdmf_common.DynamicTableRegion( ...
        'table', types.untyped.ObjectView(ElectrodesDynamicTable), ...
        'description', 'all electrodes', ...
        'data', (0: length(ElectrodesDynamicTable.id.data)-1)');

end