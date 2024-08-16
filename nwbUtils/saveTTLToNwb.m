function saveTTLToNwb(nwbFile, TTLTable, TTLFields)

    if nargin < 3
        TTLFields = fieldnames(TTLTable);
    end

    nwb = nwbRead(nwbFile, 'ignorecache');

    trials = types.core.TimeIntervals( ...
    'colnames', TTLFields, ...
    'description', 'trial data and properties');
    
    for i = 1: size(TTLTable, 2)
        rowValue = cell(1, length(TTLFields));
        for j = 1: length(TTLFields)
            if ~isempty(TTLTable(i).(TTLFields{j}))
                rowValue{j} = TTLTable(i).(TTLFields{j});
            else
                rowValue{j} = '';
            end
        end

        rowArgs = [TTLFields(:)'; rowValue];
        % rowArgs = [rowArgs(:)]';
        trials.addRow(rowArgs{:});
    end
     
    % trials.toTable();
    nwb.intervals_trials = trials;

    saveNWB(nwb, nwbFile);

end