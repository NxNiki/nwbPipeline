function clustersFixedIdx = getFixClusterIndex()

mainHandle = getHandles(1);
mainHandle = guidata(mainHandle);
clustersFixedIdx = find(mainHandle.clusterFixed);