

logFile = 'neuralynx/CSC_micro/log_file/test.log';
logMessage(logFile, 'this is a test!');

%% test logMessage in parfor

logFile = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/test_logMessage.log';
parfor i = 1:10
    logMessage(logFile, 'test', 1);
end

%% test logMessage in parfor with separate log files

parfor i = 1:10
    logFile = sprintf('/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/test_logMessage_%d.log', i);
    logMessage(logFile, 'test', 1);
end