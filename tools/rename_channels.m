% rename CSC[+d].mat files by channel name for micros to run nwbPipeline on
% data unpacked by PDM (Emily's software).


exp_file_path = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/FaceRecognition/486_FaceRecognition/Experiment4';
out_file_path = '/Users/XinNiuAdmin/HoffmanMount/data/PIPELINE_vc/ANALYSIS/FaceRecognition/486_FaceRecognition';

channelFile = fullfile(exp_file_path, 'CSC_data/channelMetaData.mat');
channelFileObj = matfile(channelFile);
channels = channelFileObj.channelData;

%%

out_file_path = [out_file_path, 'Experiment-4/CSC_micro'];
if ~exist(out_file_path, "dir")
    mkdir(out_file_path);
end

shankNames = {"GA1", "GA2", "GA3", "GA4", "GB1", "GB2", "GB3", "GB4", "GC1", "GC2", "GC3", "GC4", "GD1", "GD2", "GD3", "GD4"};
new_files = {};

for i = 1: length(channels)
    
    if isempty(channels(i).brainRegion)
        continue
    end

    old_file = fullfile(exp_file_path, sprintf("CSC_data/CSC%d.mat", i));
 
    shankName = shankNames{floor((i-1)/8) + 1};
    channelIdx = mod(i - 1, 8) + 1;
    out_file_name = strjoin([shankName, '-', channels(i).brainRegion, string(channelIdx), "_001.mat"], '');
    new_file = fullfile(out_file_path, out_file_name);

    copyfile(old_file, new_file);
    new_files = [new_files; {new_file}];
end

writecell(new_files, fullfile(out_file_path, 'outFileNames.csv'));
