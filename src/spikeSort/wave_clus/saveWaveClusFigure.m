function saveWaveClusFigure(h_figs, tag, pathname, outfile)

h_fig = findobj(h_figs, 'tag', tag);
set(h_fig, 'papertype', 'usletter', 'paperorientation', 'portrait',...
    'paperunits','inches','paperposition',[.25 .25 12.5 7.8])
print(h_fig, '-djpeg', fullfile(pathname, ['fig2print_' outfile, '_', tag]));
