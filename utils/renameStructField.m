function s = renameStructField(s, oldFieldNames, newFieldNames)
    % renameStructFields Renames multiple fields in a structure.
    % 
    % s = renameStructFields(s, oldFieldNames, newFieldNames)
    %
    % Inputs:
    %   s             - The structure containing the fields to be renamed.
    %   oldFieldNames - A character array or a cell array of the current names of the fields to rename.
    %   newFieldNames - A character array or a cell array of the new names for the fields.
    %
    % Output:
    %   s - The structure with the renamed fields.
    %
    % Example:
    %   s = renameStructFields(s, {'oldField1', 'oldField2'}, {'newField1', 'newField2'});
    %   s = renameStructFields(s, 'oldField1', 'newField1');

    % Convert oldFieldNames and newFieldNames to cell arrays if they are not already
    if ischar(oldFieldNames)
        oldFieldNames = {oldFieldNames};
    end
    if ischar(newFieldNames)
        newFieldNames = {newFieldNames};
    end

    % Ensure that the number of old and new field names match
    if length(oldFieldNames) ~= length(newFieldNames)
        error('The number of old field names must match the number of new field names.');
    end

    % Loop through each pair of old and new field names
    for i = 1:length(oldFieldNames)
        oldFieldName = oldFieldNames{i};
        newFieldName = newFieldNames{i};

        % Check if the old field name exists
        if isfield(s, oldFieldName)
            % Add the new field with the same data as the old field
            s.(newFieldName) = s.(oldFieldName);

            % Remove the old field
            s = rmfield(s, oldFieldName);
        else
            warning('The field "%s" does not exist in the structure.', oldFieldName);
        end
    end
end
