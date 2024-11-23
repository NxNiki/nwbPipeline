function duplicateIdx = getDuplicates(cellArray)
    % This function checks if the input array or cell array C has duplicates
    % using the `unique` function.
    % Outputs:
    % duplicateIdx: the index of duplicated values.
    % see also: MontageConfigUI.m

    % test:
    %{
        cellArray = {'orange', 'apple', 'banana', 'apple', 'orange', 'banana', 'grape', 'apple'};
        duplicateIdx = getDuplicates(cellArray)

    %}

    duplicateIdx = [];
    visited = {};
    for i = 1:length(cellArray)
        if ismember(cellArray(i), visited)
            if ~ismember(i, duplicateIdx)
                duplicateIdx = [duplicateIdx, i];
            end
        else
            visited = [visited, cellArray(i)];
        end
    end

end
