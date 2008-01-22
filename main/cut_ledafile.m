function cut_ledafile %keep rangeview
global leda2

cmd = questdlg('Do you really want to cut the data?','Warning','Continue','Cancel','Continue');
if isempty(cmd) || strcmp(cmd, 'Cancel')
    return;
end

start = leda2.gui.rangeview.start;
ende = start + leda2.gui.rangeview.range;

%cut and update data
[ts, cs, idx] = subrange(start, ende + 1/leda2.data.samplingrate);
leda2.data.conductance.data = cs;
leda2.data.conductance.error = sqrt(mean(diff(cs).^2)/2);
leda2.data.time.data = ts - start;
leda2.data.time.timeoff = leda2.data.time.timeoff + start;
leda2.data.N = length(ts);

%cut events
eidx = find([leda2.data.events.event.time] >= start & [leda2.data.events.event.time] < ende);
leda2.data.events.event = leda2.data.events.event(eidx);
leda2.data.events.N = length(leda2.data.events.event);
for i = 1:leda2.data.events.N
    leda2.data.events.event(i).time = leda2.data.events.event(i).time - start;
end

delete_fit(0);

leda2.gui.rangeview.range = 60;
plot_data;
file_changed(1);
add2log(1,['Cut file down to selection ',sprintf('%5.2f', start),' : ',sprintf('%5.2f', ende)],1,1,1)
