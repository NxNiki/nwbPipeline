

% event_file = '/Volumes/DATA/BRData/SubjectData/574/EXP3_ABCD/20240719-184712/20240719-184712-001.nev';
% outputFile = '/Volumes/DATA/BRData/SubjectData/574/EXP3_ABCD/20240719-184712/Events_001.mat';

% event_file = '/Volumes/DATA/BRData/SubjectData/557/EXP3_ABCD_aborted/Real_task/20230206-165729/20230206-165729-001.nev';
% outputFile = '/Volumes/DATA/BRData/SubjectData/557/EXP3_ABCD_aborted/Real_task/20230206-165729/Events_001.mat';

event_file = '/Users/XinNiuAdmin/Downloads/574 ABCD MAT/20240912-163949-001.nev';
outputFile = '/Users/XinNiuAdmin/Downloads/574 ABCD MAT/Events_001.mat';

skipExist = 0;

unpackBlackRockEvent(event_file, outputFile, skipExist);

