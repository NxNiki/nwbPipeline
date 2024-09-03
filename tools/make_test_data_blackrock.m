% make a small black data for testing purpose.


% Load the NS5 file
microFile = '/Volumes/DATA/NLData/D574/EXP4_Screening2/20240720-173300/20240720-173300-001.ns5';
NSx = openNSx('report','read', microFile, 'c:15:20', 't:3:4','min', 'p:int16');
saveNSx(NSx, 'micro.ns5');


% Load NS3 file
macroFile = '/Volumes/DATA/NLData/D574/EXP4_Screening2/20240720-173300/20240720-173300-001.ns3';
NSx = openNSx('report','read', macroFile, 'c:15:20', 't:3:4','min', 'p:int16');
saveNSx(NSx, 'macro.ns3');


% Load .nev file
nevFile = '/Volumes/DATA/NLData/D574/EXP4_Screening2/20240720-173300/20240720-173300-001.nev';
Nev = openNEV(nevFile, 'c:15:20', 't:160:240', 'report', 'nowarning', 'nosave', 'nomat', 'overwrite', 'direct');
saveNEV(Nev, 'events.nev');