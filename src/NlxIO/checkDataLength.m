function data_length = checkDataLength(cscFile)

fileObj = matfile(cscFile, "Writable", false);
data = fileObj.data;
data_length = length(data(:));