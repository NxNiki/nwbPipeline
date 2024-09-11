function result = readJson(filename)

fid = fopen(filename);
raw = fread(fid, inf, '*char')';
fclose(fid);
result = jsondecode(raw);