function [clustersToPlot, sr] = getClusters(trialFolder, plotResponsive, targetLabel)
% this function is isolated from rasters_by_unit and rasters_by_unit_video.


clusterFileObj = matfile(fullfile(trialFolder, 'clusterCharacteristics.mat'));
allClusters = clusterFileObj.clusterCharacteristics;

if ~isempty(targetLabel)
    % add target label to clusters table:
    for i = 1:size(allClusters, 1)
        region = allClusters{i, 2};
        headstageLabel = regexp(region{1}, '(^G[A-D][1-8])*', 'match', 'once');
        allClusters{i, 2} = {[region{1}, '-', targetLabel.(headstageLabel)]};
    end  
end

if ismember('samplingRate', who(clusterFileObj))
    sr = clusterFileObj.samplingRate;
    fprintf('rasters_by_unit: sampling rate: %d\n', sr);
else
    sr = 32e3;
    warning('rasters_by_unit: set default sampling rate: %d', sr);
end

if plotResponsive
    clustersToPlot = allClusters(allClusters.numSelective > 0 & allClusters.cluster_num > 0, :);
    clustersToPlot = sortrows(clustersToPlot,'selectivity','descend');
else
    clustersToPlot = allClusters(allClusters.cluster_num > 0 & allClusters.firingRate > .15, :); %& allClusters.rejectCluster == 0, :);
    clustersToPlot = sortrows(clustersToPlot,'csc_num','ascend');
end
end