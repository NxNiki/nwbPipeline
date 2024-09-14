function par = updateParamForCluster(par, spikeFile)
% add additional parameters for automatica clustering (SPC).

    [outputPath, fileName, ~] = fileparts(spikeFile);
    channel = regexp(fileName, ".*(?=_spikes)", "match", "once");
    par.channel = channel;

    par.fname_in = fullfile(outputPath, ['tmp_data_wc_' channel]);
    par.fname = fullfile(outputPath, ['data_' channel]);
    par.fnamespc = fullfile(outputPath, ['data_wc_' channel]);

    par.filename = spikeFile;

end
