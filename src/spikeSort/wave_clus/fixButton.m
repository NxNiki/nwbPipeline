function fixButton(hObject, handles, class, userDataIdx, handleKey)

    USER_DATA = get(handles.wave_clus_figure, 'userdata');
    classes = USER_DATA{6};
    fix_class = find(classes==class);
    if get(handles.(handleKey), 'value') == 1
        USER_DATA{userDataIdx} = fix_class;
    else
        USER_DATA{userDataIdx} = [];
    end
    set(handles.wave_clus_figure,'userdata', USER_DATA)
    h_figs=get(0,'children');
    h_fig4 = findobj(h_figs, 'tag', 'wave_clus_aux');
    h_fig3 = findobj(h_figs, 'tag', 'wave_clus_aux1');
    h_fig2 = findobj(h_figs, 'tag', 'wave_clus_aux2');
    h_fig1 = findobj(h_figs, 'tag', 'wave_clus_aux3');

    set(h_fig4, 'userdata', USER_DATA)
    set(h_fig3, 'userdata', USER_DATA)
    set(h_fig2, 'userdata', USER_DATA)
    set(h_fig1, 'userdata', USER_DATA)

    guidata(hObject, handles);

end
