function varargout = getUserData(index)
% get elements specified by index from userData

    if nargin < 1
        % get all userData
        index = [];
    end
    
    h_fig = getHandles(1);
    userData = get(h_fig, 'UserData'); % 1 by n cell array, see wave_clus.m
    
    if ~isempty(index)
        varargout = cell(1, length(index));
        for i = 1:length(index)
            varargout{i} = getData(index(i));
        end
    else
        % return all userData:
        varargout{1} = userData;
    end

    function res = getData(index)
        % set sampling rate if it is empty.

        if index > length(userData)
            if index == 18
                samplingRate = questdlg('What was the sampling rate?', 'SR', '30000', '32000', '40000', '32000');
                res = eval(samplingRate);
                userData{18} = res;
                set(h_fig, 'userdata', userData)
            else
                res = [];
            end
        else
            res = userData{index};
        end
    end

end



