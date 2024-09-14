function s = renameStructFields(s, oldFieldNames, newFieldNames)
    % renameStructFields Renames multiple fields in a structure or structure array.
    %
    % s = renameStructFields(s, oldFieldNames, newFieldNames)
    %
    % Inputs:
    %   s             - The structure or structure array containing the fields to be renamed.
    %   oldFieldNames - A character array or a cell array of the current names of the fields to rename.
    %   newFieldNames - A character array or a cell array of the new names for the fields.
    %
    % Output:
    %   s - The structure or structure array with the renamed fields.
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

    % Define an anonymous function to rename fields in a single structure
    renameFields = @(x) renameFieldsInStruct(x, oldFieldNames, newFieldNames);

    % Use arrayfun to apply the renaming function to each element in the structure array
    s = arrayfun(renameFields, s);

    function x = renameFieldsInStruct(x, oldNames, newNames)
        % Nested function to rename fields in a single structure
        for i = 1:length(oldNames)
            oldName = oldNames{i};
            newName = newNames{i};

            if isfield(x, oldName)
                x.(newName) = x.(oldName);
                x = rmfield(x, oldName);
            else
                warning('The field "%s" does not exist in the structure.', oldName);
            end
        end
    end
end
