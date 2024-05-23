function fullPath = replacePath(fullPath, replacePath)
% IO files are generated with full path, which are different across platform.
% This is used to change path when IO files are generated across platform
% (i.e. on mac and hoffman).

    [~, fileName, ext] = fileparts(fullPath);
    fullPath = [replacePath, filesep, fileName, ext];
end