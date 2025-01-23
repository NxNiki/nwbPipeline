function varargout = getUserData(index)
    if nargin < 1
        index = [];
    end

    h_figs=get(0, 'children');
    h_fig = findobj(h_figs, 'tag', 'wave_clus_figure');
    UserData = get(h_fig, 'UserData');
    
    if ~isempty(index)
        varargout = cell(1, length(index));
        for i = 1:length(index)
            varargout{i} = UserData{index(i)};
        end
    else
        varargout{1} = UserData;
    end

end