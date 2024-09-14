function clu_aux = permuteClu(clu, ipermut, numSpikes)

    clu_aux = zeros(size(clu, 1), numSpikes + 2) - 1;  % when update classes from clu, not selected elements go to cluster 0
    clu_aux(:,ipermut+2) = clu(:,(1:length(ipermut))+2);
    clu_aux(:,1:2) = clu(:,1:2);

end
