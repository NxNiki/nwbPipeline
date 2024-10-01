function [ADBitVolts header] = Nlx_readCSCheader(fileName,displayHeader)

header = Nlx2MatCSC_v3(fileName,[0 0 0 0 0],1,1);

if isempty(header)
    ADBitVolts = NaN;
else

    findADBitVolts = cellfun(@(x)~isempty(regexp(x,'ADBitVolts', 'once')),header);
    ADBitVolts = regexp(header{findADBitVolts},'(?<=ADBitVolts\s)[\d\.e\-]+','match');
    ADBitVolts = str2double(ADBitVolts{1});
end
% ADBitVolts = str2num(header{15}(14:end))
if exist('displayHeader','var') && ~isempty(displayHeader) && displayHeader
disp(header)
end
