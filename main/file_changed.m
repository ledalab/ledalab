function file_changed(on)
global leda2

leda2.file.changed = on;

if leda2.intern.batchmode
    return;
end

if on
    set(leda2.gui.fig_main,'Name',[leda2.intern.name,' V',num2str(leda2.intern.version,'%1.2f'),':   ',fullfile(leda2.file.pathname,leda2.file.filename),'*']);
else
    set(leda2.gui.fig_main,'Name',[leda2.intern.name,' V',num2str(leda2.intern.version,'%1.2f'),':   ',fullfile(leda2.file.pathname,leda2.file.filename)]);
end
