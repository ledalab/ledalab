function event = getuserdefeventdata(fullpath)

[time markernr] = textread(fullpath,'%f\t%d');

for ev = 1:length(markernr)

    event(ev).time = time(ev); 
    event(ev).name = num2str(markernr(ev));
    event(ev).nid = markernr(ev);
    event(ev).userdata = [];

end
