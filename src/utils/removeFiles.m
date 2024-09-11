function files = removeFiles(files, pattern)
% this is usually used to remove hidden files

    if nargin < 2
        pattern = '^\.';
    end

    idx = cellfun(@(x)isMatch(x, pattern), files);
    files(idx) = [];

    function match = isMatch(fileName, pattern)
        [~, fname, ext] = fileparts(fileName);
        match = ~isempty(regexp([fname, ext], pattern, 'once'));
    end

end