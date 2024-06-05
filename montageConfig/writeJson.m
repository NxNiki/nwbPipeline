function writeJson(data, jsonFilename)

jsonText = jsonencode(data, 'PrettyPrint', true);
% Write the JSON file
fid = fopen(jsonFilename, 'w');
if fid ~= -1
    fwrite(fid, jsonText, 'char');
    fclose(fid);
    disp(['Configuration saved to ', jsonFilename]);
else
    error('Failed to write to JSON file.');
end
