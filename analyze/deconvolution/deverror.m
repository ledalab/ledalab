function err = deverror(v, elim)

idx = v > 0 & v < elim;
err = 1 + ( sum(v(idx))/elim - sum(idx) ) / length(v);
