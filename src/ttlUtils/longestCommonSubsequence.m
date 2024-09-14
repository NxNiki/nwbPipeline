function [idx1, idx2, L] = longestCommonSubsequence(arr1, arr2)

    % This function finds the longest common subsequence that respects the frequencies
    % of element occurrences up to each point in the arrays.
    n = length(arr1);
    m = length(arr2);

    % Dynamic programming table initialization
    % L(i, j) will hold the length of the LCS of arr1(1:i) and arr2(1:j)
    L = zeros(1, m+1);

    % We will also track the actual subsequences in a cell array and the
    % index that constructs the subsequence for arr1 and arr2:
    idx1 = cell(1, m+1);
    idx2 = cell(1, m+1);

    % Build the LCS table
    for i = 1:n
        for j = 1:m
            if arr1(i) == arr2(j)
                % If elements match, extend the best previous LCS
                L(1, j+1) = L(1, j) + 1;
                idx1{1, j+1} = [idx1{1, j}, i];
                idx2{1, j+1} = [idx2{1, j}, j];
            else
                % Otherwise, take the best of the two possible extensions without this element
                if L(1, j) > L(1, j+1)
                    L(1, j+1) = L(1, j);
                    idx1{1, j+1} = idx1{1, j};
                    idx2{1, j+1} = idx2{1, j};
                else
                    L(1, j+1) = L(1, j+1);
                    idx1{1, j+1} = idx1{1, j+1};
                    idx2{1, j+1} = idx2{1, j+1};
                end
            end
        end
    end

    % The longest common subsequence with respect to frequency
    idx1 = idx1{end, end};
    idx2 = idx2{end, end};

end
