function setUserData(data, index)
    
    if nargin < 2
        index = [];
    end

    h_figs=get(0, 'children');
    h_fig = findobj(h_figs, 'tag', 'wave_clus_figure');
    if isempty(index)
        userData = data;
    else
        userData = get(h_fig, 'UserData');
        for i = 1:length(index)
            if iscell(data) && length(data) == length(index)
                userData{index(i)} = data{i};
            else
                userData{index(i)} = data;
            end
        end
    end

    set(h_fig, 'userdata', userData);

end