function isDuplicate = hasDuplicates(C)
    % This function checks if the input array or cell array C has duplicates
    % using the `unique` function.
    % Outputs:
    % isDuplicate - Returns true if duplicates are found, otherwise false.

    % Get the unique values and the index arrays ia and ic
    [~, ia, ic] = unique(C);

    % Check if the lengths of ia and ic are the same
    if length(ia) == length(ic)
        isDuplicate = false;
    else
        isDuplicate = true;
    end
end
