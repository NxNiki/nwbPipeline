function S = removeEmptyFields(S, removeValues, removeFields)

    if nargin < 2
        % If no removeValues provided, default to checking only empty values
        removeValues = {[]};  % This will handle empty fields only
    else
        % Always include empty value in the list to check
        removeValues = [{[]}, removeValues];
    end

    if nargin == 3 && ~isempty(removeFields)
        S = rmfield(S, removeFields);
    end

    % Get all field names from the struct array
    fields = fieldnames(S);

    % Identify fields that match the removeValues in all structs
    isFieldToRemove = arrayfun(@(s) structfun(@(f) any(cellfun(@(v) isequal(f, v), removeValues)), s), S, 'UniformOutput', false);

    % Convert the result to a matrix where each column represents a field
    isRemoveMatrix = cat(2, isFieldToRemove{:});

    % Find fields that match the removeValues across all structs
    fieldsToRemove = fields(all(isRemoveMatrix, 2));

    % Remove the identified fields from all structs
    S = rmfield(S, fieldsToRemove);

end
