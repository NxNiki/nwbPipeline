% unpack the macro neuralynx data.

patientId = 570;
expId = 5;

filePath = '/Volumes/DATA/NLData/D570/EXP5_Movie_24_Sleep/2024-01-27_00-01-35';
outFilePath = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/MovieParadigm/570_MovieParadigm';

%%
files = getFileNames(filePath, '.ncs', 17384);

% we assume the macro files always start with 'R' or 'L' in the file name:
macroFiles = regexp(files, '^[RL].*[0-9]*.ncs', 'match', 'once');
macroFiles = macroFiles(cellfun(@(x)~isempty(x), macroFiles));
macroFiles = cellfun(@(x)fullfile(filePath, x), macroFiles, UniformOutput=false);

outFilePath = [outFilePath, sprintf('/Experiment%d/CSC_macro/', expId)];
if ~exist(outFilePath, "dir")
    mkdir(outFilePath);
end

unpackData(macroFiles, outFilePath)










