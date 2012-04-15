function edits_cb(flag)
global leda2

rgview = leda2.gui.rangeview;

switch flag
    case 1,
        if isnumstr(get(rgview.edit_start,'String'))
            rgview.start = str2double(get(rgview.edit_start,'String'));
        end
        if isnumstr(get(rgview.edit_range,'String'))
            rgview.range = str2double(get(rgview.edit_range,'String'));
        end
        
    case 2,
        rg_end = str2double(get(rgview.edit_end,'String'));
        if rg_end > rgview.start
            rgview.range = rg_end - rgview.start;
        else
            rg_end = rgview.start + rgview.range;
            set(rgview.edit_end,'String',rg_end);
        end
        
    case 3, 
        rgview.start = get(rgview.slider,'Value');
        
    case 4,
        leda2.gui.overview.max = str2double(get(leda2.gui.overview.edit_max,'String'));
        leda2.gui.overview.min = str2double(get(leda2.gui.overview.edit_min,'String'));
        set(leda2.gui.overview.ax, 'Ylim',[leda2.gui.overview.min, leda2.gui.overview.max]);
        refresh_fitoverview;
        
    case 5,
        eventnr = str2double(get(leda2.gui.eventinfo.edit_eventnr,'String'));
                eventnr = withinlimits(eventnr, 1, leda2.data.events.N);

    case 6,
        if leda2.gui.eventinfo.current_event
            eventnr = leda2.gui.eventinfo.current_event - 1;
            eventnr = max(1, eventnr);
        else
            eventnr = find([leda2.data.events.event.time] < leda2.gui.rangeview.start);
            if ~isempty(eventnr)
                eventnr = eventnr(end);
            else
                eventnr = 1;
            end
        end
        
    case 7,
        if leda2.gui.eventinfo.current_event
            eventnr = leda2.gui.eventinfo.current_event + 1;
            eventnr = min(leda2.data.events.N, eventnr);
        else
            eventnr = find([leda2.data.events.event.time] > leda2.gui.rangeview.start);
            if ~isempty(eventnr)
                eventnr = eventnr(1);
            else
                eventnr = leda2.data.events.N;
            end
        end
end

if leda2.data.events.N > 0
    if flag >=5 && flag <=7 %edit events
        event_time = leda2.data.events.event(eventnr).time;
        rgview.start = event_time - leda2.pref.eventWindow(1);
        rgview.range = sum(leda2.pref.eventWindow);
        leda2.gui.eventinfo.showEvent = eventnr;
    end
end
leda2.gui.rangeview = rgview;
change_range;



function bool = isnumstr(inp)
bool = ~isempty(inp) && ~isempty(str2double(inp));
