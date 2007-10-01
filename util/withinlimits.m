function w_out = withinlimits(w_in, lowerlimit, upperlimit)

w_out = max(min(w_in, upperlimit),lowerlimit);
