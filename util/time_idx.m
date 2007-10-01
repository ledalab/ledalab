function [idx, time0_adj] = time_idx(time, time0)

idx = find(time >= time0);
if ~isempty(idx)
    idx = idx(1);
    time0_adj = time(idx);
    
    %check if there is a closer idex before
    if time0_adj ~= time(1) 
        time0_adjbefore = time(idx-1);
        if abs(time0 - time0_adjbefore) < abs(time0 - time0_adj)
            idx = idx - 1;
            time0_adj = time0_adjbefore;
        end
    end
    
else
    idx = [];
    time0 = [];
end
