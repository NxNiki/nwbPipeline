function updateClusterUnit(hObject, eventdata, handles, class)
clusterType = get(eventdata.NewValue, 'String'); % Get the selected button's label

% Get all buttons in the Button Group
% buttons = get(hObject, 'Children');
% Since 'Children' orders buttons in reverse, correct the index
% index = length(buttons) - index + 1;

buttons = {'Single', 'Multi', 'Noise'};
index = find(ismember(buttons, clusterType));

% Save the selected index in handles
handles.clusterUnitType(class) = index; % Save index
guidata(hObject, handles);