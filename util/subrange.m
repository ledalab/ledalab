function [ts, cs, t_idx] = subrange(t1, t2)
global leda2

t_idx = find(leda2.data.time.data >= t1 & leda2.data.time.data <= t2);

ts = leda2.data.time.data(t_idx);
cs = leda2.data.conductance.data(t_idx);
