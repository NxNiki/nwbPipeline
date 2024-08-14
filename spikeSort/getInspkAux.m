function ipermut = getInspkAux(par, inspk)

    naux = min(par.max_spk, size(inspk,1));
    ipermut = [];
    if par.permut == 'n'
        % GOES FOR TEMPLATE MATCHING IF TOO MANY SPIKES.
        if size(inspk,1) > par.max_spk
            % take first 'par.max_spk' spikes as an input for SPC
            inspk_aux = inspk(1:naux,:);
        else
            inspk_aux = inspk;
        end
    else
        % GOES FOR TEMPLATE MATCHING IF TOO MANY SPIKES.
        if size(inspk,1) > par.max_spk
            % random selection of spikes for SPC
            ipermut = randperm(length(inspk));
            ipermut(naux+1:end) = [];
            inspk_aux = inspk(ipermut,:);
        else
            ipermut = randperm(size(inspk,1));
            inspk_aux = inspk(ipermut,:);
        end
    end
    
    %INTERACTION WITH SPC
    save(par.fname_in, 'inspk_aux', '-ascii');

end