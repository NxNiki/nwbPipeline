function closeAuxFigures()

% Close aux figures
% EM: It's inefficient to close all of these if you're just going to open
% them again shortly. Set to visible off instead.

aux_figs = getHandles(2:7);

for i=1:length(aux_figs)
    aux_fig = aux_figs(i);
    set(0, 'currentFigure', aux_fig);
    set(aux_fig, 'visible', 'off');
    ch = get(aux_fig, 'children');
    arrayfun(@(x)cla(x,'reset'), ch);
end

end