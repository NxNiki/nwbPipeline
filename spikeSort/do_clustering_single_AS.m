function do_clustering_single_AS(spikeFile, spikeCodeFile, outputPath, min_spikes4SPC)

% load spikes and spike codes:
spikeFileObj = matfile(spikeFile, "Writable", true);
spikes = spikeFileObj.spikes;
param = spikeFileObj.param;

spikeCodeFileObj = matfile(spikeCodeFile);
spikeCodes = spikeCodeFileObj.spikeCodes;

par = set_parameters;
par = update_parameters(par, param, 'clus'); 
par = update_parameters(par, param, 'batch_plot');

% par.filename = spikeFile;
par.reset_results = true;

check_WC_params(par)

% if isfield(par,'channels') && ~isnan(par.channels)
%   par.max_inputs = par.max_inputs * par.channels;
% end

par = updateParamForCluster(par, spikeFile);

% REJECT SPIKES
% SPK quantity check 1
nspkBeforeReject = size(spikes,1);
spikeIdxRejected = [];
if ~isempty(spikeCodes) && nspkBeforeReject >= min_spikes4SPC
    [spikeIdxRejected, rejectionThresh, spikeCodes, probabilityParams] = getSpikesToReject(spikeCodes);
    spikes(spikeIdxRejected,:) = [];
end

nspk = size(spikes,1);
if nspk < min_spikes4SPC
    warning('MyComponent:noValidInput', 'Not enough spikes (%d/%d) in the file: \n%s', nspk, nspkBeforeReject, spikeFile);
    return
end

% CALCULATES INPUTS TO THE CLUSTERING ALGORITHM.
inspk = wave_features(spikes, par);     % takes wavelet coefficients.
par.inputs = size(inspk, 2);            % number of inputs to the clustering
ipermut = getInspkAux(par, inspk);

try
    [clu, tree] = run_cluster(par);
catch err
    warning('MyComponent:ERROR_SPC', 'Error in SPC');
    disp(err);
    return
end

% save spc results to spike file:
spikeFileObj.clu = clu;
spikeFileObj.tree = tree;

[clust_num, temp, auto_sort] = find_temp(tree, clu, par);

if ~isempty(ipermut)
    clu = permuteClu(clu, ipermut, nspk);
end

classes = zeros(1, size(clu, 2)-2);
for c = 1: length(clust_num)
    aux = clu(temp(c), 3:end) + 1 == clust_num(c);
    classes(aux) = c;
end

if par.permut == 'n'
    classes = [classes zeros(1, max(size(spikes,1) - par.max_spk, 0))];
end

Temp = [];
% Classes should be consecutive numbers
classes_names = nonzeros(sort(unique(classes)));
for i= 1:length(classes_names)
    c = classes_names(i);
    if c~= i
        classes(classes == c) = i;
    end
    Temp(i) = temp(i);
end

% IF TEMPLATE MATCHING WAS DONE, THEN FORCE
if (size(spikes,1)> par.max_spk || (par.force_auto))
    f_in  = spikes(classes~=0,:);
    f_out = spikes(classes==0,:);
    class_in = classes(classes~=0);
    class_out = force_membership_wc(f_in, class_in, f_out, par);
    forced = classes==0;
    classes(classes==0) = class_out;
    forced(classes==0) = 0;
else
    forced = zeros(1, size(spikes,1));
end

gui_status = struct();
gui_status.current_temp =  max(temp);
gui_status.auto_sort_info = auto_sort;
gui_status.original_classes = zeros(size(classes));

for i=1:max(classes)
    gui_status.original_classes(classes==i) = clust_num(i);
end

% remove by mahal distance --------------
s = warning; warning('off')
for i=1:max(classes)
    inCluster = classes == i;
    nSpikes = sum(inCluster);
    nFeatures = size(inspk, 2);
    if nSpikes > nFeatures
        M = mahal(inspk, inspk(inCluster, :));
        Lspk = 1-gammainc(M/2, nFeatures/2);
        % Lspk = 1-chi2cdf(M, nFeatures);
        removeFromClust = inCluster & Lspk' < 5e-3;
        classes(removeFromClust) = 0;
    end
end
warning(s);
% -----------------------------------------
current_par = par;
par = struct;
par = update_parameters(par, current_par, 'relevant');
par = update_parameters(par, current_par, 'batch_plot');

par.sorting_date = datestr(now);

% save spike timestamps and exp start timestamp:
spikeTimestamps = spikeFileObj.spikeTimestamps;
spikeTimestamps(spikeIdxRejected) = [];
timestampsStart = spikeFileObj.timestampsStart;

cluster_class(:, 1) = classes;
cluster_class(:, 2) = spikeTimestamps;

outFileName = fullfile(outputPath, ['times_', current_par.channel, '.mat']);
outFileNameTemp = fullfile(outputPath, ['times_', current_par.channel, 'temp.mat']);

cluster_class(:, 1) = rejectPositiveSpikes(spikes, cluster_class(:, 1), par);
save(outFileNameTemp, 'cluster_class', 'timestampsStart', 'spikeIdxRejected', 'par', 'forced', 'Temp', 'gui_status', 'inspk', '-v7.3');

if ~isempty(ipermut)
    save(outFileNameTemp, 'ipermut', '-append');
end

movefile(outFileNameTemp, outFileName);

end
% mahal function incase system doesn't have it
function d = mahal(Y, X)
[rx, cx] = size(X);
[ry, cy] = size(Y);

m = mean(X, 1);
M = m(ones(ry,1), :);
C = X - m(ones(rx,1), :);
[Q, R] = qr(C, 0);

ri = R'\(Y-M)';
d = sum(ri.*ri, 1)'*(rx-1);

end

