function idx = subrange_idx(t, t1, t2)
%global leda2

%idx = find(leda2.data.time.data >= t1 & leda2.data.time.data <= t2);  %too imprecise
t1_idx = time_idx(t, t1);
t2_idx = time_idx(t, t2);

if ~isempty(t1_idx) && ~isempty(t2_idx)
    idx = t1_idx:t2_idx;
else
    idx = [];
end
