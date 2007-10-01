function import_data(datatype)
global leda2

switch datatype
    case 'mat', ext = {'*.mat'};
    case 'text', ext = {'*.txt'};
    case 'cassylab', ext = {'*.lab'};
    case 'userdef', ext = {'*.txt'};
        
    otherwise
        msgbox('Unknown filetype.','Info')
        return
end

[filename, pathname] = uigetfile(ext, ['Choose a ',datatype,' data-file']);
if all(filename == 0) || all(pathname == 0) %Cancel
    return
end

%Try to import the selected data-file
try
    switch datatype
        case 'mat',
            load([pathname, filename]);
            conductance = data.conductance;
            time = data.time;
            event = data.event;
            
         case 'text'
            [time, conductance, event] = gettextdata([pathname, filename]);
            
        case 'cassylab',
            [time, conductance, event] = getcassydata([pathname, filename]);

        case 'userdef'
            [time, conductance, event] = getuserdefdata([pathname, filename]);
            
    end
catch
    add2log(0,['Unable to import ',pathname, filename,': No valid ',datatype,' data-file or corrupt file.'],1,1,0,1,0,1)
    return
end

time = time(:)'; %force data in row
conductance = conductance(:)';

timeoffset = time(1);
time = time - timeoffset;


close_ledafile;
if leda2.file.open, return; end %closing failed


%Load data
leda2.data.conductance.data = conductance;
leda2.data.time.data = time;
leda2.data.time.timeoff = timeoffset;
conductanceerror = sqrt(mean(diff(conductance).^2)/2);
leda2.data.conductance.error = conductanceerror;


%Get events
if ~isempty(event)
    leda2.data.events.event = event;  %event must contain at least event.time
    leda2.data.events.N = length(event);
    event_fields = fieldnames(event);

    %set dummy values for missing event-info
    for ev = 1:leda2.data.events.N
        
        leda2.data.events.event(ev).time = leda2.data.events.event(ev).time - timeoffset;        
        if ~any(strcmp(event_fields, 'name'))
            leda2.data.events.event(ev).name = '';
        end
        if ~any(strcmp(event_fields, 'nid'))
            leda2.data.events.event(ev).nid = [];
        end
        if ~any(strcmp(event_fields, 'userdata'))
            leda2.data.events.event(ev).userdata = [];
        end
    end

end

leda2.file.filename = filename;
leda2.file.pathname = pathname;
leda2.file.date = clock;
leda2.file.log = {};
leda2.file.version = leda2.intern.version;
leda2.intern.current_dir = leda2.file.pathname;
cd(pathname);
leda2.file.open = 1;
file_changed(1);
add2log(1,[, ' Imported ',pathname, filename,' successfully.'],1,1,1);

plot_data;
