function event = getuserdefeventdata(fullpath)

M = dlmread(fullpath);

for ev = 1:size(M,1)
    
    event(ev).time = M(ev,1)/1000;
    if size(M,2) > 1
        event(ev).name = num2str(M(ev,2));
        event(ev).nid = M(ev,2);
    else
        event(ev).name = '1';
        event(ev).nid = 1;
    end
    event(ev).userdata = [];
    
end
