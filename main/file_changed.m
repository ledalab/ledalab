function file_changed(on)
global leda2

leda2.file.changed = on;

if leda2.intern.batchmode
    return;
end

if on
    set(leda2.gui.fig_main,'Name',[leda2.intern.name,' ',leda2.intern.versiontxt,':   ',fullfile(leda2.file.pathname,leda2.file.filename),'*']);
else
    set(leda2.gui.fig_main,'Name',[leda2.intern.name,' ',leda2.intern.versiontxt,':   ',fullfile(leda2.file.pathname,leda2.file.filename)]);
end
