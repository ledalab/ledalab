function err = deverror(v, elim)

err = 0;
err = err + sum(v(v > elim(1) & v < 0) / elim(1));
err = err + sum(v(v > 0 & v < elim(2)) / elim(2));
err = err + length(find(v <= elim(1) | v >= elim(2)));
err = err/length(v);
