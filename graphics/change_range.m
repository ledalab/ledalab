function change_range
global leda2

if leda2.intern.batchmode
    return;
end
if ~any(strcmp(fieldnames(leda2.data),'time')) %no data loaded yet
    return;
end

rgview = leda2.gui.rangeview;
time = leda2.data.time;

%check if field (X-values) is within overview
if rgview.start < 0, rgview.start = 0; end
if rgview.range > time.data(end),
    rgview.range = time.data(end);
end
if (rgview.start + rgview.range) >= time.data(end),
    rgview.start = time.data(end) - rgview.range;
end
set(rgview.edit_start,'String',num2str(rgview.start,'%3.2f'))
set(rgview.edit_range,'String',num2str(rgview.range,'%3.2f'))
set(rgview.edit_end,'String',num2str(rgview.start + rgview.range,'%3.2f'))

%check Y-limits for overview-field = rangeview
cond_rg.data = leda2.data.conductance.data(subrange_idx(time.data, rgview.start, rgview.start + rgview.range)); %(round(1+rgview.start*leda2.data.samplingrate) : round((rgview.start + rgview.range)*leda2.data.samplingrate));
if isempty(leda2.analysis)
    cond_rg.min = min(cond_rg.data);
else
    cond_rg.min = min(leda2.analysis.tonicData(subrange_idx(time.data, rgview.start, rgview.start + rgview.range)));
end
cond_rg.max = max(cond_rg.data);
cond_rg.yrange = max(.5, (cond_rg.max - cond_rg.min)*1.2); %%%
rg_bottom = (cond_rg.max + cond_rg.min)/2 - cond_rg.yrange/2;
rg_top = (cond_rg.max + cond_rg.min)/2 + cond_rg.yrange/2;
rgview.bottom = rg_bottom;
rgview.top = rg_top;
rg_start = rgview.start;
rg_end = rgview.start + rgview.range;

set(leda2.gui.overview.rangefld, 'XData', [rg_start, rg_start, rg_end, rg_end],'YData',[rg_bottom, rg_top, rg_top, rg_bottom]);
set(rgview.ax, 'XLim', [rg_start, rg_end], 'Ylim', [rg_bottom, rg_top]);

%Slider
rem = time.data(end) - rgview.range;
if rem <= 0,
    rem = 2; %dummy value > 0
end
sliderstep = rgview.range/rem;
smallsliderstep = sliderstep/10;
if sliderstep > 1, sliderstep = 1; end
if smallsliderstep > 1, smallsliderstep = 1; end
set(leda2.gui.rangeview.slider,'sliderstep',[smallsliderstep, sliderstep],'min',0,'max',rem,'Value',rgview.start)


%Events
if leda2.data.events.N > 0
    set(rgview.eventtxt,'Visible','off')
    set(rgview.markerL,'LineWidth',1);
    eventTimeList = [leda2.data.events.event.time];
    eventInRange = find(eventTimeList > rg_start & eventTimeList < rg_end);
    for ev = eventInRange
        ev_t = leda2.data.events.event(ev).time;
        set(rgview.eventtxt(ev),'Position',[ev_t-rgview.range/200, rg_top-.1, 1],'HorizontalAlignment','right','Visible','on');     %MB 29.01.2014
    end
    if ~isempty(eventInRange)
        if leda2.gui.eventinfo.showEvent %was just set in event-info
            current_event = leda2.gui.eventinfo.showEvent;
        else
            current_event = eventInRange(1); %else first event is current event
        end
        leda2.gui.eventinfo.current_event = current_event;
        set(rgview.markerL(current_event),'LineWidth',2);

        set(leda2.gui.eventinfo.edit_eventnr,'String',num2str(current_event));
        set(leda2.gui.eventinfo.txt_name,'String',leda2.data.events.event(current_event).name);
        set(leda2.gui.eventinfo.txt_time,'String',sprintf('%5.2f',leda2.data.events.event(current_event).time));
        if ischar(leda2.data.events.event(current_event).userdata)
            udtxt = [', ',leda2.data.events.event(current_event).userdata];
        else
            udtxt = '';
        end
        set(leda2.gui.eventinfo.txt_niduserdata,'String',[num2str(leda2.data.events.event(current_event).nid), udtxt]);
    else
        leda2.gui.eventinfo.current_event = 0;
        set(leda2.gui.eventinfo.edit_eventnr,'String','');
        set(leda2.gui.eventinfo.txt_name,'String','');
        set(leda2.gui.eventinfo.txt_time,'String','');
        set(leda2.gui.eventinfo.txt_niduserdata,'String','');
    end
end
leda2.gui.eventinfo.showEvent = 0;


%%%%
leda2.gui.rangeview = rgview;
showfit;%(rgview.start, rgview.start + rgview.range); %%%%
