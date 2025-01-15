function updateClusterUnit(eventdata, class)
clusterType = get(eventdata.NewValue, 'String'); % Get the selected button's label

% Get all buttons in the Button Group
% buttons = get(hObject, 'Children');
% Since 'Children' orders buttons in reverse, correct the index
% index = length(buttons) - index + 1;

buttons = {'Single', 'Multi', 'Noise'};
index = find(ismember(buttons, clusterType));

mainHandle = findobj('tag', 'wave_clus_figure');
mainHandles = guidata(mainHandle);

% set unit type index in the main UI:
mainHandles.clusterUnitType(class) = index; % Save index
guidata(mainHandle, mainHandles); % Save changes to the main UI's handles structure
