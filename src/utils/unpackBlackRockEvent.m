function unpackBlackRockEvent(inFile, outputFile, skipExist)

outputPath = fileparts(outputFile);
if ~exist(outputPath, "dir")
    mkdir(outputPath);
end

if exist(outputFile, "file") && skipExist
    warning('skip unpack event file: %s', outputFile);
end

NEV = openNEV(inFile, "read", "8bits");

% ttl timestamps
ttl(:,1)=(double(NEV.Data.SerialDigitalIO.TimeStampSec))';
% ttl messages
ttl(:,2)=(double(NEV.Data.SerialDigitalIO.UnparsedData))';
% remove ttls that did not come in on 129:
mostTTLinsertions = mode(NEV.Data.SerialDigitalIO.InsertionReason);
if mostTTLinsertions ~=1
    warning(['Expected TTLs To come in on channel 1. Using TTLs from ',num2str(mostTTLinsertions),' instead. Look into this if your TTLs look weird.'])
end
indsToRemove = NEV.Data.SerialDigitalIO.InsertionReason ~= mostTTLinsertions;
ttl(indsToRemove,:) = [];

% parse continuous messages (time stamps < 1 msec apart)
if 0
    ttl(:,3)=[0; diff(ttl(:,1))];
    ttl(:,3)=(ttl(:,3)>0.03);
    ttl(1,3)=1; %add a 1 on top of first ttl 4. this will designate beginning of message.
    ind_mess_start=find(ttl(:,3)); %indices where 1's are--that's where each message starts
    widths=[diff(ind_mess_start);length(ttl(ind_mess_start(end):end,3))];% make widths of messages to break up the matrix at the end of ea message
    colwidths=ones(size(ttl,2),1)';

    TTL=mat2cell(ttl,widths,colwidths);
else
    TTL = ttl;
end

ts = TTL(:,1);
ttlCode = TTL(:,2);

% code copied from parseDAQ_BlackRockTTLs in PDM:
dt = diff(ts);
inds = dt<.03;
ttlCode(inds) = []; ts(inds) = [];
ttlCode(ttlCode>128) = ttlCode(ttlCode>128)-128;
inds = ttlCode==0 | ttlCode > 100;
ts(inds) = [];
ttlCode(inds) = [];

outFileObj = matfile(outputFile, "Writable", true);
outFileObj.TTLs = ttlCode;
outFileObj.timestamps = ts;


end
