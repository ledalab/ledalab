function delete_fit(show_log)
global leda2

%Delete Fit
leda2.analysis = [];

if leda2.intern.batchmode
    return;
end

%Delete fitoverview
ch = get(leda2.gui.overview.ax,'Children');
delete(ch(strcmp(get(ch,'Tag'),'FitComp')));
leda2.gui.overview.driver = [];
leda2.gui.overview.tonic_component = [];
leda2.gui.overview.phasic = [];
leda2.gui.overview.overshoot = [];

%Delete rangeview components
ch = get(leda2.gui.rangeview.ax,'Children');
delete(ch(strcmp(get(ch,'Tag'),'FitComp')));
%Delete driver-view components
ch = get(leda2.gui.driver.ax,'Children');
delete(ch);

refresh_fitinfo;

if show_log
    plot_data;
    add2log(1,'Fit deleted',1,1,1)
end
