function close_ledafile
global leda2

if ~leda2.file.open
    return;
end

%Unsaved data can be saved now
if leda2.file.changed && ~leda2.intern.batchmode
    choice = questdlg('Do you want to save the current file?','Save File','Yes','No','Cancel','Yes');
    if strcmp(choice,'Yes')
        save_ledafile;
    elseif strcmp(choice,'Cancel')
        return
    end
end

%clear filedependent vars
leda2.data.events.event = [];
leda2.data.events.N = 0;
leda2.file.version = 0;
leda2.file.date = 0;
delete_fit(0);

leda2.file.open = 0;
