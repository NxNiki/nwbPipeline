function [handles, handlesIndex] = getHandles(uiIdx)

if nargin < 1
    uiIdx = 1:7;
end

h_figs = findall(0, 'Type', 'figure');
UITags = {'wave_clus_figure', 'wave_clus_aux', 'wave_clus_aux1', 'wave_clus_aux2', 'wave_clus_aux3', 'wave_clus_aux4', 'wave_clus_aux5'};

handles = [];
handlesIndex = [];
for i = uiIdx
    uiFig = findall(h_figs, 'tag', UITags{i});
    if ~isempty(uiFig)
        handles = [handles, uiFig];
        handlesIndex = [handlesIndex, i];
        disp(['Tag: ', get(uiFig, 'Tag')]);
        disp(['Visible: ', get(uiFig, 'Visible')]);
    end
end