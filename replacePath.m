function fullPath = replacePath(fullPath, replacePath)
    [~, fileName, ext] = fileparts(fullPath);
    fullPath = [replacePath, filesep, fileName, ext];
end