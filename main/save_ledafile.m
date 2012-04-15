function save_ledafile(save_as)
global leda2

if nargin < 1
    save_as = 0;
end
if ~leda2.file.open
    return
end
leda2.file.filename = [leda2.file.filename(1:end-4),'.mat'];

if save_as
    [filename, pathname] = uiputfile([leda2.file.filename], 'Save file as ..');
    if all(filename == 0) || all(pathname == 0) %Cancel
        return
    end
    leda2.file.filename = filename;
    leda2.file.pathname = pathname;
else
    filename = leda2.file.filename;
    pathname = leda2.file.pathname;
end
file = fullfile(pathname, filename);


%Prepare data for saving
fileinfo.version = leda2.intern.version;
fileinfo.date = clock;
fileinfo.log = leda2.file.log;

data.conductance = leda2.data.conductance.data;
data.time = leda2.data.time.data;
data.timeoff = leda2.data.time.timeoff;
data.event = leda2.data.events.event;

savevars = {'fileinfo','data'};

if ~isempty(leda2.analysis)
    analysis = leda2.analysis;
    if strcmp(leda2.analysis.method,'nndeco')
        analysis = rmfield(analysis, {'phasicComponent', 'phasicRemainder'}); %#ok<NASGU>
    end
    savevars = [savevars, {'analysis'}];
end


try
    save(file, savevars{:}); %, '-v6'
    add2log(1,[' Saved ',file,' in V',num2str(leda2.intern.version,'%1.2f')],1,1,1);
    fileinfo.log = leda2.file.log; %if it there is no error, save again with updated filelog
    save(file, savevars{:});  %, '-v6

    file_changed(0);
catch
    add2log(1,[' Saving ',file,' failed!!!'],1,1,0,1,0,1);
end


leda2.file.date = fileinfo.date;
leda2.file.version = fileinfo.version;
%if save_as
update_prevfilelist(pathname, filename);
%end
