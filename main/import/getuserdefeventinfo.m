function event = getuserdefeventinfo(fullpath)

[date time soundnr markernr wavfile] = textread(fullpath,'%s\t%s\tSound\t%d\tMarker\t%d\t%s');

for ev = 1:length(markernr)

    %event(ev).time = time; %this line is only used if event times have not previously be imported with the data file
    event(ev).name = wavfile{ev};
    event(ev).nid = markernr(ev);
    event(ev).userdata.date(ev) = date(ev);
    event(ev).userdata.time(ev) = time(ev);
    event(ev).userdata.soundnr(ev) = soundnr(ev);

end
