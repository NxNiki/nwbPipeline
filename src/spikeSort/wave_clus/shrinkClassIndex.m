function classValue = shrinkClassIndex(classValue)
% remove gaps in class values. 0 or negative values will be ignored.

% Example:
%{
    classValue = [1, 1, 1, 3, 3, 3, 5, 5, 5, 0, 0, 0, -1, -1, -1];
    classValue = shrinkClassIndex(classValue)
%}

    positiveIdx = classValue > 0;
    uniqueVals = unique(classValue(positiveIdx));

    for i = 1:length(uniqueVals)
        classValue(classValue == uniqueVals(i)) = i;
    end
end
