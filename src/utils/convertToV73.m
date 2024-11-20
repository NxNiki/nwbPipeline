function convertToV73(inputFile)

    % Check if the input file exists
    if ~isfile(inputFile)
        error('Input file does not exist.');
    end

    fid=fopen(inputFile);
    txt=char(fread(fid,[1,140],'*char'));
    txt=[txt,0];
    txt=txt(1:find(txt==0,1,'first')-1);

    if contains(txt, 'MATLAB 7.3 MAT-file')
        fprintf('%s\n is already in v7.3\n', inputFile);
        disp(txt)
        return
    end

    fprintf('save %s as v7.3\n', inputFile)

    % If loading fails, it might be an older format
    % Load the data from the non-v7.3 .mat file
    data = load(inputFile);

    % Create a backup of the original file
    movefile(inputFile, strrep(inputFile, '.mat', '_non73.mat'));

    % Save the data to a new .mat file in v7.3 format
    save(inputFile, '-struct', 'data', '-v7.3');
    
end