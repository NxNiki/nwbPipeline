function handles = updateParam(hObject, handles, parKey)

    USER_DATA = get(handles.wave_clus_figure, 'userdata');
    par = USER_DATA{1};
    par.(parKey) = str2double(get(hObject, 'String'));
    USER_DATA{1} = par;
    set(handles.wave_clus_figure,'userdata', USER_DATA);
    
    guidata(hObject, handles);

end