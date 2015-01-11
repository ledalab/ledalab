function import_eventdata(infotype)
global leda2

if ~leda2.file.open
    add2log(0,'No open file',1,1,0,1,0,1)
    return;
end

[filename, pathname] = uigetfile({'*.txt';'*.dat'},'Choose an event-data file');

if all(filename == 0) || all(pathname == 0) %Cancel
    return
end


switch infotype
    case 'default',
        event = getevents([pathname, filename]);
    case 'userdef',
        event = getuserdefeventdata([pathname, filename]);
end


if ~isempty(event)
    leda2.data.events.event = [];
    
    N = length(event);
    event_fields = fieldnames(event);
    
    for ev = 1:N
        if any(strcmp(event_fields, 'time'))
            leda2.data.events.event(ev).time = event(ev).time;
        end
        if any(strcmp(event_fields, 'name'))
            leda2.data.events.event(ev).name = event(ev).name;
        end
        if any(strcmp(event_fields, 'nid'))
            leda2.data.events.event(ev).nid = event(ev).nid;
        end
        if any(strcmp(event_fields, 'userdata'))
            leda2.data.events.event(ev).userdata = event(ev).userdata;
        end
        leda2.data.events.N = N;
    end
       
    plot_data;
    
end
