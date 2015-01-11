function import_eventinfo(infotype)
global leda2


[filename, pathname] = uigetfile({'*.txt';'*.dat'},'Choose an event-info file');

if all(filename == 0) || all(pathname == 0) %Cancel
    return
end


switch infotype
    case 'default',
        event = getevents([pathname, filename]);    
    case 'userdef',
        event = getuserdefeventinfo([pathname, filename]);
end


if ~isempty(event)
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
        end


    %plot updated event-names
    for ev = 1:N
        set(leda2.gui.rangeview.eventtxt(ev),'String',sprintf('%.1f:  %s (%s)',leda2.data.events.event(ev).time, leda2.data.events.event(ev).name, num2str(leda2.data.events.event(ev).nid)));
    end

end
