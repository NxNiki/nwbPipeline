function length = checkDataLength(cscFile)

fileObj = matfile(cscFile, "Writable", false);
length = fileObj.data;
