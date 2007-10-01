function idx = subrange_idx(t1, t2)
global leda2

idx = find(leda2.data.time.data >= t1 & leda2.data.time.data < t2);
