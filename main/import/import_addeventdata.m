function import_addeventdata(infotype)
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
    old_event = leda2.data.events.event; % copy old events
    old_events_N = leda2.data.events.N; % copy number of old events
    leda2.data.events.event = []; % clear events structure
        
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
        leda2.data.events.N = N; % get number of new events
    end
    
    new_event = leda2.data.events.event; % copy new events
    leda2.data.events.event = []; % clear events structure
    
    
    %% merge old and new events
    % merge old and new marker structure array
    M = [old_event, new_event];
    
    % convert structure array to cell array
    Mfields = fieldnames(M);
    Mcell = struct2cell(M);
    sz = size(Mcell);       
    Mcell = reshape(Mcell, sz(1), []); % convert to a matrix
    Mcell = Mcell'; % Make each field a column
    
    % sort 
    Mcell = sortrows(Mcell, 1); % Sort by first field "time"  

    % convert it back to a structure array:
    Mcell = reshape(Mcell', sz); % put back into original cell array format
    Msorted = cell2struct(Mcell, Mfields, 1); % convert to struct
    
    % pass over new values to leda2.data.events
    leda2.data.events.event = Msorted;
    leda2.data.events.N = leda2.data.events.N + old_events_N;
    
    plot_data;
    
end
