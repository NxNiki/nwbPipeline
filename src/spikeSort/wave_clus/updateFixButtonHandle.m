function updateFixButtonHandle(hObject, handles)
% reset all fix buttons to off (0).

USER_DATA = get(handles.wave_clus_figure, 'userdata');
par = USER_DATA{1};

set(handles.fix1_button,'value',0);
set(handles.fix2_button,'value',0);
set(handles.fix3_button,'value',0);

for i=4:par.max_clus
    par.(['fix', num2str(i)]) = 0;
end

USER_DATA{1} = par;
set(handles.wave_clus_figure, 'userdata', USER_DATA)

guidata(hObject, handles);

end
