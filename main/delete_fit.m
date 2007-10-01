function delete_fit(show_log)
global leda2

%Delete Fit
leda2.analyze.initialvalues = [];
leda2.analyze.initialsolution = [];
leda2.analyze.epoch = [];
leda2.analyze.fit = [];
leda2.analyze.history = [];

%Delete fitoverview
ch = get(leda2.gui.overview.ax,'Children');
delete(ch(strcmp(get(ch,'Tag'),'FitComp')));
leda2.gui.overview.residual = [];
leda2.gui.overview.tonic_component = [];
leda2.gui.overview.phasic = [];

refresh_fitinfo;
manual_edit('exit_medit');
    
if show_log
    plot_data;
    add2log(1,'Fit deleted',1,1,1)
end
